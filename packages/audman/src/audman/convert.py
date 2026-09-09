from __future__ import annotations

import base64
import json
import os
import re
import shutil
import stat
import subprocess
import tempfile
import unicodedata
from concurrent.futures import ThreadPoolExecutor, as_completed
from contextlib import contextmanager
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from threading import Event, Lock
from typing import Callable, Iterator

from mutagen import File as MutagenFile
from mutagen import MutagenError
from mutagen.flac import CueSheet, FLAC, Picture
from mutagen.oggopus import OggOpus

LEGACY_BACKUP_DIR_NAME = ".audman_backup"

LOSSLESS_EXTENSIONS = {
    ".aif",
    ".aifc",
    ".aiff",
    ".alac",
    ".caf",
    ".flac",
    ".m4a",
    ".wav",
    ".wave",
}
LOSSLESS_CONVERT_EXTENSIONS = LOSSLESS_EXTENSIONS - {".flac"}
OPUS_INPUT_EXTENSIONS = LOSSLESS_EXTENSIONS | {".mp3", ".ogg"}
FLAC_EXTENSIONS = {".flac"}

LOSSLESS_OPUS_BITRATE = "192k"


class AudmanError(RuntimeError):
    pass


@dataclass(frozen=True)
class ConversionResult:
    source: Path
    output: Path | None
    action: str


@dataclass(frozen=True)
class ConversionRun:
    results: list[ConversionResult]
    backup_dir: Path | None


@dataclass(frozen=True)
class BackupPlan:
    root: Path
    source_root: Path


@dataclass(frozen=True)
class FileIdentity:
    device: int
    inode: int
    size: int
    mtime_ns: int
    ctime_ns: int


ProgressCallback = Callable[[int, int], None]


def convert_lossless_path(
    path: Path,
    backup: bool = True,
    force: bool = False,
    jobs: int | None = None,
    progress: ProgressCallback | None = None,
) -> ConversionRun:
    return _convert_path(
        path,
        mode="lossless",
        backup=backup,
        force=force,
        jobs=jobs,
        progress=progress,
    )


def convert_lossy_path(
    path: Path,
    backup: bool = True,
    force: bool = False,
    jobs: int | None = None,
    progress: ProgressCallback | None = None,
) -> ConversionRun:
    return _convert_path(
        path,
        mode="lossy",
        backup=backup,
        force=force,
        jobs=jobs,
        progress=progress,
    )


def compress_flac_path(
    path: Path,
    backup: bool = True,
    force: bool = False,
    jobs: int | None = None,
    progress: ProgressCallback | None = None,
) -> ConversionRun:
    return _convert_path(
        path,
        mode="compress-flac",
        backup=backup,
        force=force,
        jobs=jobs,
        progress=progress,
    )


def convert_lossless_single(
    input_file: Path, output_file: Path, force: bool = False
) -> ConversionResult:
    input_file = _require_file(input_file)
    if not _is_lossless(input_file):
        raise AudmanError(f"not a supported lossless file: {input_file}")
    if input_file.suffix.lower() == ".flac":
        raise AudmanError("FLAC inputs are handled by 'audman compress flac'")
    output_file = _prepare_single_output(
        input_file, output_file, suffix=".flac", force=force
    )
    _encode_single(
        input_file,
        output_file,
        force=force,
        expected_codec="flac",
        encode=lambda dest: _encode_flac(input_file, dest),
    )
    return ConversionResult(input_file, output_file, "converted")


def convert_lossy_single(
    input_file: Path, output_file: Path, force: bool = False
) -> ConversionResult:
    input_file = _require_file(input_file)
    _ensure_suffix(input_file, OPUS_INPUT_EXTENSIONS)
    output_file = _prepare_single_output(
        input_file, output_file, suffix=".opus", force=force
    )
    _encode_single(
        input_file,
        output_file,
        force=force,
        expected_codec="opus",
        encode=lambda dest: _encode_opus(
            input_file, dest, opus_bitrate_for(input_file)
        ),
    )
    return ConversionResult(input_file, output_file, "converted")


def compress_flac_single(
    input_file: Path, output_file: Path, force: bool = False
) -> ConversionResult:
    input_file = _require_file(input_file)
    _ensure_suffix(input_file, FLAC_EXTENSIONS)
    output_file = _prepare_single_output(
        input_file, output_file, suffix=".flac", force=force
    )
    _encode_single(
        input_file,
        output_file,
        force=force,
        expected_codec="flac",
        encode=lambda dest: _encode_flac(input_file, dest),
    )
    return ConversionResult(input_file, output_file, "compressed")


def _convert_path(
    path: Path,
    mode: str,
    backup: bool,
    force: bool,
    jobs: int | None,
    progress: ProgressCallback | None,
) -> ConversionRun:
    path = _absolute_path(path)
    _ensure_no_symlinks(path)

    if path.is_file():
        _validate_explicit_input(path, mode)
        items = [path]
    elif path.is_dir():
        items = _matching_files(path, _extensions_for_mode(mode))
    else:
        raise AudmanError(f"input path does not exist: {path}")

    _preflight_outputs(items, mode=mode, force=force)

    total = len(items)
    completed = 0
    progress_lock = Lock()
    cancelled = Event()
    backup_plan = _create_backup_plan(path) if backup and items else None

    if progress is not None:
        progress(0, total)

    def convert_item(item: Path) -> ConversionResult:
        nonlocal completed
        try:
            if cancelled.is_set():
                raise AudmanError("conversion cancelled")
            return _convert_file(
                item,
                mode=mode,
                backup_plan=backup_plan,
                force=force,
                cancelled=cancelled,
            )
        except BaseException:
            cancelled.set()
            raise
        finally:
            with progress_lock:
                completed += 1
                if progress is not None:
                    progress(completed, total)

    if path.is_file():
        results = [convert_item(path)]
    else:
        with ThreadPoolExecutor(max_workers=_normalize_jobs(jobs)) as executor:
            futures = {
                executor.submit(convert_item, item): index
                for index, item in enumerate(items)
            }
            ordered_results: list[ConversionResult | None] = [None] * len(items)
            try:
                for future in as_completed(futures):
                    ordered_results[futures[future]] = future.result()
            except BaseException:
                cancelled.set()
                for future in futures:
                    future.cancel()
                raise
            results = [result for result in ordered_results if result is not None]

    backup_dir = _used_backup_dir(backup_plan)
    return ConversionRun(results, backup_dir)


def _convert_file(
    path: Path,
    mode: str,
    backup_plan: BackupPlan | None,
    force: bool,
    cancelled: Event,
) -> ConversionResult:
    output = _output_for_mode(path, mode)
    if output is None:
        return ConversionResult(path, None, "skipped")

    source_identity = _file_identity(path)
    output_identity = None
    if output != path:
        _ensure_output_available(output, force=force)
        output_identity = _optional_file_identity(output)

    with _temporary_output(output) as staged:
        if mode in {"lossless", "compress-flac"}:
            _encode_flac(path, staged)
            expected_codec = "flac"
        elif mode == "lossy":
            _encode_opus(path, staged, opus_bitrate_for(path))
            expected_codec = "opus"
        else:
            raise AudmanError(f"unknown conversion mode: {mode}")

        _validate_output(staged, expected_codec, source=path)
        if cancelled.is_set():
            raise AudmanError("conversion cancelled")
        _commit_conversion(
            source=path,
            output=output,
            staged=staged,
            backup_plan=backup_plan,
            force=force,
            source_identity=source_identity,
            output_identity=output_identity,
        )

    action = "compressed" if mode == "compress-flac" else "converted"
    return ConversionResult(path, output, action)


def _prepare_single_output(
    source: Path,
    output: Path,
    suffix: str,
    force: bool,
) -> Path:
    output = _absolute_path(output)
    _ensure_no_symlinks(output)
    if _same_path(output, source):
        raise AudmanError("input and output files must be different")
    if output.suffix.lower() != suffix:
        raise AudmanError(f"output file must use the {suffix} extension: {output}")
    _ensure_parent(output)
    _ensure_output_available(output, force=force)
    return output


def _encode_single(
    source: Path,
    output: Path,
    force: bool,
    expected_codec: str,
    encode: Callable[[Path], None],
) -> None:
    source_identity = _file_identity(source)
    output_identity = _optional_file_identity(output)
    with _temporary_output(output) as staged:
        encode(staged)
        _validate_output(staged, expected_codec, source=source)
        _require_file_unchanged(source, source_identity, "input")
        _install_checked_output(
            staged,
            output,
            expected=output_identity,
            force=force,
        )


@contextmanager
def _temporary_output(output: Path) -> Iterator[Path]:
    with tempfile.TemporaryDirectory(prefix=".audman-", dir=output.parent) as directory:
        yield Path(directory) / output.name


def _output_for_mode(path: Path, mode: str) -> Path | None:
    suffix = path.suffix.lower()
    if mode == "lossless":
        if suffix == ".flac" or not _is_lossless(path):
            return None
        return path.with_suffix(".flac")
    if mode == "lossy":
        if suffix not in OPUS_INPUT_EXTENSIONS:
            return None
        return path.with_suffix(".opus")
    if mode == "compress-flac":
        return path if suffix == ".flac" else None
    raise AudmanError(f"unknown conversion mode: {mode}")


def _validate_explicit_input(path: Path, mode: str) -> None:
    suffix = path.suffix.lower()
    if mode == "lossless":
        if suffix == ".flac":
            raise AudmanError("FLAC inputs are handled by 'audman compress flac'")
        if suffix not in LOSSLESS_CONVERT_EXTENSIONS or not _is_lossless(path):
            raise AudmanError(f"not a supported lossless file: {path}")
        return
    if mode == "lossy":
        _ensure_suffix(path, OPUS_INPUT_EXTENSIONS)
        return
    if mode == "compress-flac":
        _ensure_suffix(path, FLAC_EXTENSIONS)
        return
    raise AudmanError(f"unknown conversion mode: {mode}")


def _preflight_outputs(items: list[Path], mode: str, force: bool) -> None:
    destinations: dict[str, Path] = {}
    for item in items:
        output = _output_for_mode(item, mode)
        if output is None or output == item:
            continue
        key = _path_key(output)
        previous = destinations.get(key)
        if previous is not None:
            raise AudmanError(
                f"multiple inputs target the same output: {previous}, {item} -> {output}"
            )
        destinations[key] = item
        _ensure_output_available(output, force=force)


def _commit_conversion(
    source: Path,
    output: Path,
    staged: Path,
    backup_plan: BackupPlan | None,
    force: bool,
    source_identity: FileIdentity,
    output_identity: FileIdentity | None,
) -> None:
    _require_file_unchanged(source, source_identity, "input")
    if output != source:
        _require_file_unchanged(output, output_identity, "output")

    if backup_plan is None:
        if output == source:
            _replace_existing_output(staged, output, source_identity)
            return

        quarantined = _quarantine_file(
            source,
            source_identity,
            staged.parent,
            label="source",
        )
        try:
            _install_checked_output(
                staged,
                output,
                expected=output_identity,
                force=force,
            )
        except BaseException:
            _restore_quarantined(quarantined, source)
            raise
        try:
            quarantined.unlink()
        except OSError as exc:
            _restore_quarantined(quarantined, source)
            raise AudmanError(
                f"converted {source}, but could not remove the original: {exc}"
            ) from exc
        return

    moved: list[tuple[Path, Path]] = []
    try:
        moved.append(
            (
                source,
                _backup_checked_file(
                    source,
                    source_identity,
                    backup_plan,
                    staged.parent,
                    label="source",
                ),
            )
        )
        if output != source and output_identity is not None:
            if not force:
                raise AudmanError(f"output file already exists: {output}")
            moved.append(
                (
                    output,
                    _backup_checked_file(
                        output,
                        output_identity,
                        backup_plan,
                        staged.parent,
                        label="output",
                    ),
                )
            )
        else:
            _require_file_unchanged(output, None, "output")
        _install_staged(staged, output, force=False)
    except BaseException as exc:
        try:
            _restore_backups(moved)
        except AudmanError as restore_error:
            raise AudmanError(
                f"conversion failed and backup restoration also failed: {restore_error}"
            ) from exc
        raise


def _install_checked_output(
    staged: Path,
    output: Path,
    expected: FileIdentity | None,
    force: bool,
) -> None:
    _require_file_unchanged(output, expected, "output")
    if expected is None:
        _install_staged(staged, output, force=False)
        return
    if not force:
        raise AudmanError(f"output file already exists: {output}")
    _replace_existing_output(staged, output, expected)


def _replace_existing_output(
    staged: Path,
    output: Path,
    expected: FileIdentity,
) -> None:
    previous = _quarantine_file(
        output,
        expected,
        staged.parent,
        label="previous-output",
    )
    try:
        _install_staged(staged, output, force=False)
    except BaseException:
        _restore_quarantined(previous, output)
        raise
    previous.unlink(missing_ok=True)


def _backup_checked_file(
    path: Path,
    expected: FileIdentity,
    backup_plan: BackupPlan,
    temporary_directory: Path,
    label: str,
) -> Path:
    quarantined = _quarantine_file(
        path,
        expected,
        temporary_directory,
        label=label,
    )
    try:
        return _move_to_backup(quarantined, backup_plan, original_path=path)
    except BaseException:
        _restore_quarantined(quarantined, path)
        raise


def _quarantine_file(
    path: Path,
    expected: FileIdentity,
    temporary_directory: Path,
    label: str,
) -> Path:
    quarantined = temporary_directory / f"{label}-{path.name}"
    _require_file_unchanged(path, expected, label)
    try:
        os.replace(path, quarantined)
    except OSError as exc:
        raise AudmanError(f"could not secure {path} before replacement: {exc}") from exc
    except BaseException:
        if os.path.lexists(quarantined) and not os.path.lexists(path):
            _restore_quarantined(quarantined, path)
        raise
    try:
        current = _file_identity(quarantined)
        if not _same_moved_identity(current, expected):
            raise AudmanError(f"{label} file changed during conversion: {path}")
    except BaseException:
        _restore_quarantined(quarantined, path)
        raise
    return quarantined


def _restore_quarantined(quarantined: Path, original: Path) -> None:
    if os.path.lexists(original):
        recovery = _unique_recovery_path(original)
        os.replace(quarantined, recovery)
        raise AudmanError(
            f"could not restore {original}; preserved prior file at {recovery}"
        )
    os.replace(quarantined, original)


def _install_staged(staged: Path, output: Path, force: bool) -> None:
    try:
        if force:
            os.replace(staged, output)
        else:
            os.link(staged, output)
            staged.unlink()
    except FileExistsError as exc:
        raise AudmanError(f"output file already exists: {output}") from exc
    except OSError as exc:
        raise AudmanError(f"could not install output file {output}: {exc}") from exc


def opus_bitrate_for(path: Path) -> str:
    suffix = path.suffix.lower()

    if _is_lossless(path):
        return LOSSLESS_OPUS_BITRATE

    bitrate = _probe_audio_bitrate(path)

    if suffix == ".mp3":
        if bitrate >= 300_000:
            return "192k"
        if bitrate >= 200_000:
            return "128k"
        return "96k"

    if suffix in {".ogg", ".m4a"}:
        if bitrate >= 250_000:
            return "160k"
        if bitrate >= 120_000:
            return "128k"
        return "96k"

    return "96k"


def _is_lossless(path: Path) -> bool:
    codec = _probe_codec(path)
    return codec in {"alac", "flac"} or codec.startswith("pcm_")


def _matching_files(path: Path, extensions: set[str]) -> list[Path]:
    matches = []
    backup_base = _absolute_path(_backup_base_dir())
    for item in sorted(path.rglob("*")):
        relative_parts = item.relative_to(path).parts
        if (
            LEGACY_BACKUP_DIR_NAME in relative_parts
            or any(part.startswith(".audman-") for part in relative_parts)
            or _path_is_within(item, backup_base)
        ):
            continue
        if item.is_symlink():
            raise AudmanError(f"symbolic links are not supported: {item}")
        if item.is_file() and item.suffix.lower() in extensions:
            matches.append(item)
    return matches


def _extensions_for_mode(mode: str) -> set[str]:
    if mode == "lossless":
        return LOSSLESS_CONVERT_EXTENSIONS
    if mode == "lossy":
        return OPUS_INPUT_EXTENSIONS
    if mode == "compress-flac":
        return FLAC_EXTENSIONS
    raise AudmanError(f"unknown conversion mode: {mode}")


def _normalize_jobs(jobs: int | None) -> int:
    if jobs is None:
        return os.cpu_count() or 1
    return max(1, jobs)


def _encode_flac(source: Path, dest: Path) -> None:
    attached_pictures = _validate_streams(source)
    pictures = _embedded_pictures(source)
    if attached_pictures and not pictures:
        raise AudmanError(f"could not preserve embedded artwork from {source}")
    cuesheet = _flac_cuesheet(source)
    if _probe_chapters(source) and cuesheet is None:
        raise AudmanError(f"cannot preserve chapters in a FLAC file: {source}")
    sample_args = _flac_sample_args(source)

    _run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-nostdin",
            "-xerror",
            "-err_detect",
            "explode",
            "-n",
            "-i",
            str(source),
            "-map",
            "0:a:0",
            "-map_metadata",
            "0",
            "-map_chapters",
            "0",
            "-codec:a",
            "flac",
            "-compression_level",
            "12",
            *sample_args,
            "-f",
            "flac",
            str(dest),
        ]
    )
    _write_flac_metadata(dest, pictures, cuesheet)


def _encode_opus(source: Path, dest: Path, bitrate: str) -> None:
    attached_pictures = _validate_streams(source)
    pictures = _embedded_pictures(source)
    if attached_pictures and not pictures:
        raise AudmanError(f"could not preserve embedded artwork from {source}")
    if _flac_cuesheet(source) is not None or _probe_chapters(source):
        raise AudmanError(
            f"cannot preserve chapters or a FLAC CUESHEET in an Opus file: {source}"
        )

    _run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-nostdin",
            "-xerror",
            "-err_detect",
            "explode",
            "-n",
            "-i",
            str(source),
            "-map",
            "0:a:0",
            "-map_metadata",
            "0",
            "-map_chapters",
            "0",
            "-codec:a",
            "libopus",
            "-b:a",
            bitrate,
            "-vbr",
            "on",
            "-application",
            "audio",
            "-f",
            "opus",
            str(dest),
        ]
    )
    _write_opus_pictures(dest, pictures)


def _flac_sample_args(path: Path) -> list[str]:
    info = _probe_audio_info(path)
    sample_format = str(info.get("sample_fmt") or "").lower()
    if sample_format.startswith(("flt", "dbl")):
        raise AudmanError(
            f"floating-point audio cannot be represented losslessly as FLAC: {path}"
        )

    bit_depth = _int_value(info.get("bits_per_raw_sample")) or _int_value(
        info.get("bits_per_sample")
    )
    if bit_depth > 32:
        raise AudmanError(f"FLAC cannot preserve {bit_depth}-bit audio: {path}")
    if bit_depth > 24:
        return [
            "-sample_fmt:a",
            "s32",
            "-bits_per_raw_sample:a",
            "32",
            "-strict",
            "experimental",
        ]
    return []


def _probe_audio_info(path: Path) -> dict:
    data = _ffprobe_json(
        path,
        "stream=codec_name,sample_fmt,bits_per_sample,bits_per_raw_sample",
    )
    try:
        stream = data["streams"][0]
    except (KeyError, IndexError, TypeError) as exc:
        raise AudmanError(
            f"could not read audio stream information from {path}"
        ) from exc
    if not isinstance(stream, dict):
        raise AudmanError(f"ffprobe returned invalid audio stream data for {path}")
    return stream


def _int_value(value: object) -> int:
    try:
        return int(value or 0)
    except (TypeError, ValueError):
        return 0


def _validate_streams(path: Path) -> int:
    streams = _probe_streams(path)
    audio_streams = [
        stream for stream in streams if stream.get("codec_type") == "audio"
    ]
    if len(audio_streams) != 1:
        raise AudmanError(
            f"expected exactly one audio stream in {path}; found {len(audio_streams)}"
        )

    attached_pictures = 0
    for stream in streams:
        if stream.get("codec_type") == "audio":
            continue
        disposition = stream.get("disposition") or {}
        if stream.get("codec_type") == "video" and disposition.get("attached_pic") == 1:
            attached_pictures += 1
            continue
        index = stream.get("index", "unknown")
        stream_type = stream.get("codec_type", "unknown")
        raise AudmanError(
            f"cannot preserve {stream_type} stream {index} in the target audio format"
        )
    return attached_pictures


def _probe_streams(path: Path) -> list[dict]:
    proc = _run(
        [
            "ffprobe",
            "-v",
            "quiet",
            "-show_entries",
            "stream=index,codec_type:stream_disposition=attached_pic",
            "-of",
            "json",
            str(path),
        ],
        capture=True,
    )
    data = _load_json(proc.stdout, path)
    streams = data.get("streams")
    if not isinstance(streams, list) or not all(
        isinstance(stream, dict) for stream in streams
    ):
        raise AudmanError(f"ffprobe returned invalid stream data for {path}")
    return streams


def _probe_chapters(path: Path) -> list[dict]:
    proc = _run(
        [
            "ffprobe",
            "-v",
            "quiet",
            "-show_chapters",
            "-of",
            "json",
            str(path),
        ],
        capture=True,
    )
    data = _load_json(proc.stdout, path)
    chapters = data.get("chapters")
    if not isinstance(chapters, list) or not all(
        isinstance(chapter, dict) for chapter in chapters
    ):
        raise AudmanError(f"ffprobe returned invalid chapter data for {path}")
    return chapters


def _embedded_pictures(path: Path) -> list[Picture]:
    try:
        media = MutagenFile(path)
    except (MutagenError, OSError) as exc:
        raise AudmanError(f"could not read metadata from {path}: {exc}") from exc
    if media is None:
        return []

    pictures = [Picture(picture.write()) for picture in getattr(media, "pictures", [])]
    tags = getattr(media, "tags", None)
    if tags is None:
        return pictures

    getall = getattr(tags, "getall", None)
    if callable(getall):
        for frame in getall("APIC"):
            pictures.append(
                _new_picture(
                    data=bytes(frame.data),
                    mime=frame.mime,
                    picture_type=int(frame.type),
                    description=frame.desc,
                )
            )

    for value in tags.get("metadata_block_picture", []):
        try:
            pictures.append(Picture(base64.b64decode(value, validate=True)))
        except (MutagenError, ValueError, TypeError) as exc:
            raise AudmanError(f"invalid embedded artwork in {path}") from exc

    for cover in tags.get("covr", []):
        data = bytes(cover)
        pictures.append(_new_picture(data=data, mime=_image_mime(data)))

    if not pictures:
        legacy_art = tags.get("coverart", [])
        legacy_mimes = tags.get("coverartmime", [])
        for index, value in enumerate(legacy_art):
            try:
                data = base64.b64decode(value, validate=True)
            except (ValueError, TypeError) as exc:
                raise AudmanError(f"invalid embedded artwork in {path}") from exc
            mime = (
                legacy_mimes[index] if index < len(legacy_mimes) else _image_mime(data)
            )
            pictures.append(_new_picture(data=data, mime=mime))

    return pictures


def _new_picture(
    data: bytes,
    mime: str,
    picture_type: int = 3,
    description: str = "",
) -> Picture:
    picture = Picture()
    picture.data = data
    picture.mime = mime or _image_mime(data)
    picture.type = picture_type
    picture.desc = description
    return picture


def _image_mime(data: bytes) -> str:
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if data.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    if data.startswith((b"GIF87a", b"GIF89a")):
        return "image/gif"
    if data.startswith(b"RIFF") and data[8:12] == b"WEBP":
        return "image/webp"
    return "application/octet-stream"


def _flac_cuesheet(path: Path) -> CueSheet | None:
    if path.suffix.lower() != ".flac":
        return None
    try:
        cuesheet = FLAC(path).cuesheet
        return CueSheet(cuesheet.write()) if cuesheet is not None else None
    except (MutagenError, OSError, ValueError) as exc:
        raise AudmanError(f"could not read FLAC metadata from {path}: {exc}") from exc


def _write_flac_metadata(
    path: Path,
    pictures: list[Picture],
    cuesheet: CueSheet | None,
) -> None:
    if not pictures and cuesheet is None:
        return
    try:
        output = FLAC(path)
        output.clear_pictures()
        for picture in pictures:
            output.add_picture(Picture(picture.write()))
        if cuesheet is not None:
            output.cuesheet = CueSheet(cuesheet.write())
        output.save()
    except (MutagenError, OSError, ValueError) as exc:
        raise AudmanError(f"could not preserve FLAC metadata in {path}: {exc}") from exc


def _write_opus_pictures(path: Path, pictures: list[Picture]) -> None:
    if not pictures:
        return
    try:
        output = OggOpus(path)
        if output.tags is None:
            output.add_tags()
        output.tags["metadata_block_picture"] = [
            base64.b64encode(picture.write()).decode("ascii") for picture in pictures
        ]
        output.save()
    except (MutagenError, OSError) as exc:
        raise AudmanError(
            f"could not preserve embedded artwork in {path}: {exc}"
        ) from exc


def _probe_codec(path: Path) -> str:
    data = _ffprobe_json(path, "stream=codec_name")
    try:
        return str(data["streams"][0].get("codec_name") or "").lower()
    except (KeyError, IndexError, TypeError):
        return ""


def _probe_audio_bitrate(path: Path) -> int:
    data = _ffprobe_json(path, "stream=bit_rate:format=bit_rate")
    try:
        stream_bitrate = int(data["streams"][0].get("bit_rate") or 0)
    except (KeyError, IndexError, TypeError, ValueError):
        stream_bitrate = 0
    if stream_bitrate:
        return stream_bitrate
    try:
        return int(data["format"].get("bit_rate") or 0)
    except (KeyError, TypeError, ValueError):
        return 0


def _probe_duration(path: Path) -> float:
    data = _ffprobe_json(path, "stream=duration:format=duration")
    values = []
    try:
        values.append(data["streams"][0].get("duration"))
    except (KeyError, IndexError, TypeError):
        pass
    try:
        values.append(data["format"].get("duration"))
    except (KeyError, TypeError):
        pass
    for value in values:
        try:
            duration = float(value or 0)
        except (TypeError, ValueError):
            continue
        if duration > 0:
            return duration
    raise AudmanError(f"could not determine audio duration for {path}")


def _ffprobe_json(path: Path, entries: str) -> dict:
    proc = _run(
        [
            "ffprobe",
            "-v",
            "quiet",
            "-select_streams",
            "a:0",
            "-show_entries",
            entries,
            "-of",
            "json",
            str(path),
        ],
        capture=True,
    )
    return _load_json(proc.stdout, path)


def _load_json(value: str, path: Path) -> dict:
    try:
        data = json.loads(value)
    except (json.JSONDecodeError, TypeError) as exc:
        raise AudmanError(f"ffprobe returned invalid JSON for {path}") from exc
    if not isinstance(data, dict):
        raise AudmanError(f"ffprobe returned invalid data for {path}")
    return data


def _move_to_backup(
    path: Path,
    backup_plan: BackupPlan,
    original_path: Path | None = None,
) -> Path:
    relative_path = (original_path or path).relative_to(backup_plan.source_root)
    backup_path = backup_plan.root / relative_path
    backup_path.parent.mkdir(parents=True, exist_ok=True)
    backup_path = _unique_backup_path(backup_path)
    try:
        shutil.move(str(path), str(backup_path))
    except OSError as exc:
        raise AudmanError(f"could not back up {path}: {exc}") from exc
    return backup_path


def _restore_backups(moved: list[tuple[Path, Path]]) -> None:
    errors = []
    for original, backup in reversed(moved):
        if os.path.lexists(original):
            errors.append(f"cannot restore {backup}; destination exists: {original}")
            continue
        try:
            shutil.move(str(backup), str(original))
        except OSError as exc:
            errors.append(f"could not restore {backup} to {original}: {exc}")
    if errors:
        raise AudmanError("; ".join(errors))


def _create_backup_plan(path: Path) -> BackupPlan:
    backup_base = _backup_base_dir()
    backup_base.mkdir(parents=True, exist_ok=True)
    session_name = f"{_runtime_timestamp()}-{_sanitize_target_name(path)}"

    for index in range(10_000):
        suffix = "" if index == 0 else f"-{index}"
        root = backup_base / f"{session_name}{suffix}"
        try:
            root.mkdir()
            source_root = path if path.is_dir() else path.parent
            return BackupPlan(root=root, source_root=source_root)
        except FileExistsError:
            continue

    raise AudmanError(f"could not allocate backup directory for {path}")


def _used_backup_dir(backup_plan: BackupPlan | None) -> Path | None:
    if backup_plan is None:
        return None
    if any(backup_plan.root.iterdir()):
        return backup_plan.root
    backup_plan.root.rmdir()
    return None


def _backup_base_dir() -> Path:
    state_home = os.environ.get("XDG_STATE_HOME")
    if state_home:
        return Path(state_home).expanduser() / "audman" / "backups"
    return Path.home() / ".local" / "state" / "audman" / "backups"


def _runtime_timestamp() -> str:
    return datetime.now().strftime("%Y%m%d-%H%M%S")


def _sanitize_target_name(path: Path) -> str:
    name = path.name or "root"
    sanitized = re.sub(r"[^A-Za-z0-9._-]+", "-", name).strip("-.")
    return sanitized or "target"


def _unique_backup_path(path: Path) -> Path:
    if not path.exists():
        return path
    for index in range(1, 10_000):
        candidate = path.with_name(f"{path.name}.{index}")
        if not candidate.exists():
            return candidate
    raise AudmanError(f"could not allocate unique backup path for {path}")


def _unique_recovery_path(path: Path) -> Path:
    for index in range(10_000):
        suffix = "" if index == 0 else f"-{index}"
        candidate = path.with_name(f".{path.name}.audman-recovery{suffix}")
        if not os.path.lexists(candidate):
            return candidate
    raise AudmanError(f"could not allocate recovery path for {path}")


def _require_file(path: Path) -> Path:
    path = _absolute_path(path)
    _ensure_no_symlinks(path)
    if not path.is_file():
        raise AudmanError(f"input file does not exist: {path}")
    return path


def _absolute_path(path: Path) -> Path:
    return Path(os.path.abspath(path.expanduser()))


def _path_key(path: Path) -> str:
    normalized = unicodedata.normalize("NFC", os.path.normpath(os.fspath(path)))
    return normalized.casefold()


def _path_is_within(path: Path, directory: Path) -> bool:
    path_key = _path_key(path)
    directory_key = _path_key(directory).rstrip(os.sep)
    return path_key == directory_key or path_key.startswith(f"{directory_key}{os.sep}")


def _same_path(first: Path, second: Path) -> bool:
    if os.path.lexists(first) and os.path.lexists(second):
        try:
            return os.path.samefile(first, second)
        except OSError:
            pass
    return _path_key(first) == _path_key(second)


def _optional_file_identity(path: Path) -> FileIdentity | None:
    if not os.path.lexists(path):
        return None
    try:
        details = path.lstat()
    except OSError as exc:
        raise AudmanError(f"could not inspect file {path}: {exc}") from exc
    if not stat.S_ISREG(details.st_mode):
        raise AudmanError(f"path is not a regular file: {path}")
    return FileIdentity(
        device=details.st_dev,
        inode=details.st_ino,
        size=details.st_size,
        mtime_ns=details.st_mtime_ns,
        ctime_ns=details.st_ctime_ns,
    )


def _file_identity(path: Path) -> FileIdentity:
    identity = _optional_file_identity(path)
    if identity is None:
        raise AudmanError(f"file no longer exists: {path}")
    return identity


def _require_file_unchanged(
    path: Path,
    expected: FileIdentity | None,
    label: str,
) -> None:
    if _optional_file_identity(path) != expected:
        raise AudmanError(f"{label} file changed during conversion: {path}")


def _same_moved_identity(current: FileIdentity, expected: FileIdentity) -> bool:
    return (
        current.device,
        current.inode,
        current.size,
        current.mtime_ns,
    ) == (
        expected.device,
        expected.inode,
        expected.size,
        expected.mtime_ns,
    )


def _ensure_no_symlinks(path: Path) -> None:
    for candidate in (path, *path.parents):
        if candidate.is_symlink():
            raise AudmanError(f"symbolic links are not supported: {candidate}")


def _ensure_suffix(path: Path, suffixes: set[str]) -> None:
    if path.suffix.lower() not in suffixes:
        expected = ", ".join(sorted(suffixes))
        raise AudmanError(f"unsupported input type {path.suffix}; expected {expected}")


def _ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    _ensure_no_symlinks(path.parent)


def _ensure_output_available(path: Path, force: bool) -> None:
    _ensure_no_symlinks(path)
    if not os.path.lexists(path):
        return
    if not path.is_file():
        raise AudmanError(f"output path is not a regular file: {path}")
    if not force:
        raise AudmanError(f"output file already exists: {path}")


def _validate_output(
    path: Path,
    expected_codec: str,
    source: Path | None = None,
) -> None:
    if path.is_symlink() or not path.is_file():
        raise AudmanError(f"encoder did not create a regular output file: {path}")
    if path.stat().st_size == 0:
        raise AudmanError(f"encoder created an empty output file: {path}")
    codec = _probe_codec(path)
    if codec != expected_codec:
        raise AudmanError(
            f"encoder created {codec or 'unknown'} audio instead of {expected_codec}: {path}"
        )
    output_hash = _decoded_audio_hash(path)
    if expected_codec == "flac" and source is not None:
        source_hash = _decoded_audio_hash(source)
        if output_hash != source_hash:
            raise AudmanError(f"FLAC output does not preserve the source audio: {path}")
    if expected_codec == "opus" and source is not None:
        source_duration = _probe_duration(source)
        output_duration = _probe_duration(path)
        if abs(source_duration - output_duration) > 0.05:
            raise AudmanError(f"Opus output duration differs from the source: {path}")


def _decoded_audio_hash(path: Path) -> str:
    proc = _run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-nostdin",
            "-xerror",
            "-err_detect",
            "explode",
            "-i",
            str(path),
            "-map",
            "0:a:0",
            "-codec:a",
            "pcm_s32le",
            "-f",
            "hash",
            "-hash",
            "sha256",
            "-",
        ],
        capture=True,
    )
    digest = proc.stdout.strip()
    if not digest.startswith("SHA256="):
        raise AudmanError(f"could not validate decoded audio from {path}")
    return digest


def _run(command: list[str], capture: bool = False) -> subprocess.CompletedProcess:
    try:
        return subprocess.run(
            command,
            check=True,
            text=True,
            stdout=subprocess.PIPE if capture else None,
            stderr=subprocess.PIPE if capture else None,
        )
    except FileNotFoundError as exc:
        raise AudmanError(f"missing executable: {command[0]}") from exc
    except subprocess.CalledProcessError as exc:
        detail = f": {exc.stderr.strip()}" if exc.stderr else ""
        raise AudmanError(f"command failed: {' '.join(command)}{detail}") from exc

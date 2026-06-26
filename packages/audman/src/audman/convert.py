from __future__ import annotations

import os
import json
import shutil
import subprocess
import tempfile
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path

BACKUP_DIR_NAME = ".audman_backup"

LOSSLESS_EXTENSIONS = {".flac", ".wav", ".aiff", ".aif", ".m4a"}
LOSSLESS_CONVERT_EXTENSIONS = {".wav", ".aiff", ".aif", ".m4a"}
LOSSY_EXTENSIONS = {".flac", ".ogg", ".mp3", ".m4a"}
FLAC_EXTENSIONS = {".flac"}

LOSSLESS_OPUS_BITRATE = "192k"


class AudmanError(RuntimeError):
    pass


@dataclass(frozen=True)
class ConversionResult:
    source: Path
    output: Path | None
    action: str


def convert_lossless_path(
    path: Path, backup: bool = True, jobs: int | None = None
) -> list[ConversionResult]:
    return _convert_path(path, mode="lossless", backup=backup, jobs=jobs)


def convert_lossy_path(
    path: Path, backup: bool = True, jobs: int | None = None
) -> list[ConversionResult]:
    return _convert_path(path, mode="lossy", backup=backup, jobs=jobs)


def compress_flac_path(
    path: Path, backup: bool = True, jobs: int | None = None
) -> list[ConversionResult]:
    return _convert_path(path, mode="compress-flac", backup=backup, jobs=jobs)


def convert_lossless_single(input_file: Path, output_file: Path) -> ConversionResult:
    input_file = _require_file(input_file)
    if not _is_lossless(input_file):
        raise AudmanError(f"not a supported lossless file: {input_file}")
    if input_file.suffix.lower() == ".flac":
        raise AudmanError("FLAC inputs are handled by 'audman compress flac'")
    _ensure_parent(output_file)
    _encode_flac(input_file, output_file)
    return ConversionResult(input_file, output_file, "converted")


def convert_lossy_single(input_file: Path, output_file: Path) -> ConversionResult:
    input_file = _require_file(input_file)
    _ensure_suffix(input_file, LOSSY_EXTENSIONS)
    _ensure_parent(output_file)
    _encode_opus(input_file, output_file, opus_bitrate_for(input_file))
    return ConversionResult(input_file, output_file, "converted")


def compress_flac_single(input_file: Path, output_file: Path) -> ConversionResult:
    input_file = _require_file(input_file)
    _ensure_suffix(input_file, FLAC_EXTENSIONS)
    _ensure_parent(output_file)
    _encode_flac(input_file, output_file)
    return ConversionResult(input_file, output_file, "compressed")


def _convert_path(
    path: Path, mode: str, backup: bool, jobs: int | None
) -> list[ConversionResult]:
    path = path.expanduser().resolve()

    if path.is_file():
        return [_convert_file(path, mode=mode, backup=backup)]

    if path.is_dir():
        items = _matching_files(path, _extensions_for_mode(mode))
        with ThreadPoolExecutor(max_workers=_normalize_jobs(jobs)) as executor:
            return list(
                executor.map(
                    lambda item: _convert_file(item, mode=mode, backup=backup),
                    items,
                )
            )

    raise AudmanError(f"input path does not exist: {path}")


def _convert_file(path: Path, mode: str, backup: bool) -> ConversionResult:
    suffix = path.suffix.lower()

    if mode == "lossless":
        if not _is_lossless(path):
            return ConversionResult(path, None, "skipped")

        if suffix == ".flac":
            return ConversionResult(path, None, "skipped")

        output = path.with_suffix(".flac")
        _ensure_output_available(output)
        _encode_flac(path, output)
        _backup_or_remove(path, backup=backup)
        return ConversionResult(path, output, "converted")

    if mode == "lossy":
        if suffix not in LOSSY_EXTENSIONS:
            return ConversionResult(path, None, "skipped")

        output = path.with_suffix(".opus")
        _ensure_output_available(output)
        _encode_opus(path, output, opus_bitrate_for(path))
        _backup_or_remove(path, backup=backup)
        return ConversionResult(path, output, "converted")

    if mode == "compress-flac":
        if suffix != ".flac":
            return ConversionResult(path, None, "skipped")

        return _compress_flac_in_place(path, backup=backup)

    raise AudmanError(f"unknown conversion mode: {mode}")


def _compress_flac_in_place(path: Path, backup: bool) -> ConversionResult:
    with tempfile.NamedTemporaryFile(
        prefix=f"{path.stem}.",
        suffix=".flac",
        dir=path.parent,
        delete=False,
    ) as tmp:
        tmp_path = Path(tmp.name)

    tmp_path.unlink()

    try:
        _encode_flac(path, tmp_path)
        _backup_or_remove(path, backup=backup)
        tmp_path.replace(path)
        return ConversionResult(path, path, "compressed")
    except Exception:
        tmp_path.unlink(missing_ok=True)
        raise


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
    suffix = path.suffix.lower()
    if suffix in {".flac", ".wav", ".aiff", ".aif"}:
        return True
    if suffix == ".m4a":
        return _probe_codec(path) == "alac"
    return False


def _matching_files(path: Path, extensions: set[str]) -> list[Path]:
    return [
        item
        for item in sorted(path.rglob("*"))
        if item.is_file()
        and BACKUP_DIR_NAME not in item.parts
        and item.suffix.lower() in extensions
    ]


def _extensions_for_mode(mode: str) -> set[str]:
    if mode == "lossless":
        return LOSSLESS_CONVERT_EXTENSIONS
    if mode == "lossy":
        return LOSSY_EXTENSIONS
    if mode == "compress-flac":
        return FLAC_EXTENSIONS
    raise AudmanError(f"unknown conversion mode: {mode}")


def _normalize_jobs(jobs: int | None) -> int:
    if jobs is None:
        return os.cpu_count() or 1
    return max(1, jobs)


def _encode_flac(source: Path, dest: Path) -> None:
    _run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-nostdin",
            "-i",
            str(source),
            "-map",
            "0:a:0",
            "-map_metadata",
            "0",
            "-vn",
            "-codec:a",
            "flac",
            "-compression_level",
            "12",
            str(dest),
        ]
    )


def _encode_opus(source: Path, dest: Path, bitrate: str) -> None:
    _run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-nostdin",
            "-i",
            str(source),
            "-map",
            "0:a:0",
            "-map_metadata",
            "0",
            "-vn",
            "-codec:a",
            "libopus",
            "-b:a",
            bitrate,
            "-vbr",
            "on",
            "-application",
            "audio",
            str(dest),
        ]
    )


def _probe_codec(path: Path) -> str:
    data = _ffprobe_json(path, "stream=codec_name")
    try:
        return str(data["streams"][0].get("codec_name") or "").lower()
    except (KeyError, IndexError, TypeError):
        return ""


def _probe_audio_bitrate(path: Path) -> int:
    data = _ffprobe_json(path, "stream=bit_rate")
    try:
        return int(data["streams"][0].get("bit_rate") or 0)
    except (KeyError, IndexError, TypeError, ValueError):
        return 0


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
    return json.loads(proc.stdout)


def _backup_or_remove(path: Path, backup: bool) -> None:
    if not backup:
        path.unlink()
        return

    backup_dir = path.parent / BACKUP_DIR_NAME
    backup_dir.mkdir(exist_ok=True)
    shutil.move(str(path), str(_unique_backup_path(backup_dir / path.name)))


def _unique_backup_path(path: Path) -> Path:
    if not path.exists():
        return path
    for index in range(1, 10_000):
        candidate = path.with_name(f"{path.name}.{index}")
        if not candidate.exists():
            return candidate
    raise AudmanError(f"could not allocate unique backup path for {path}")


def _require_file(path: Path) -> Path:
    path = path.expanduser().resolve()
    if not path.is_file():
        raise AudmanError(f"input file does not exist: {path}")
    return path


def _ensure_suffix(path: Path, suffixes: set[str]) -> None:
    if path.suffix.lower() not in suffixes:
        expected = ", ".join(sorted(suffixes))
        raise AudmanError(f"unsupported input type {path.suffix}; expected {expected}")


def _ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def _ensure_output_available(path: Path) -> None:
    if path.exists():
        raise AudmanError(f"output file already exists: {path}")


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

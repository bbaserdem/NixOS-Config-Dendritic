from __future__ import annotations

import subprocess
from pathlib import Path

import pytest

from audman import convert

VALIDATE_OUTPUT = convert._validate_output
PROBE_CODEC = convert._probe_codec


@pytest.fixture(autouse=True)
def backup_base(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    base = tmp_path / "state" / "audman" / "backups"
    monkeypatch.setattr(convert, "_backup_base_dir", lambda: base)
    monkeypatch.setattr(convert, "_runtime_timestamp", lambda: "20260831-161755")
    monkeypatch.setattr(convert, "_validate_output", lambda *_args, **_kwargs: None)
    monkeypatch.setattr(
        convert,
        "_probe_codec",
        lambda path: {
            ".aif": "pcm_s16be",
            ".aifc": "pcm_s16be",
            ".aiff": "pcm_s16be",
            ".alac": "alac",
            ".caf": "alac",
            ".flac": "flac",
            ".m4a": "alac",
            ".mp3": "mp3",
            ".ogg": "vorbis",
            ".wav": "pcm_s16le",
            ".wave": "pcm_s16le",
        }.get(path.suffix.lower(), ""),
    )
    return base


def write_file(path: Path, text: str = "audio") -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


def fake_encode_flac(source: Path, dest: Path) -> None:
    dest.write_text(f"flac:{source.name}", encoding="utf-8")


def fake_encode_opus(source: Path, dest: Path, bitrate: str) -> None:
    dest.write_text(f"opus:{bitrate}:{source.name}", encoding="utf-8")


@pytest.mark.parametrize(
    ("suffix", "is_lossless", "bitrate", "expected"),
    [
        (".flac", True, 0, "192k"),
        (".wav", True, 0, "192k"),
        (".mp3", False, 300_000, "192k"),
        (".mp3", False, 200_000, "128k"),
        (".mp3", False, 199_999, "96k"),
        (".ogg", False, 250_000, "160k"),
        (".ogg", False, 120_000, "128k"),
        (".ogg", False, 119_999, "96k"),
        (".m4a", False, 250_000, "160k"),
        (".m4a", False, 120_000, "128k"),
        (".m4a", False, 119_999, "96k"),
    ],
)
def test_opus_bitrate_for(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    suffix: str,
    is_lossless: bool,
    bitrate: int,
    expected: str,
) -> None:
    source = tmp_path / f"source{suffix}"
    write_file(source)
    monkeypatch.setattr(convert, "_is_lossless", lambda _path: is_lossless)
    monkeypatch.setattr(convert, "_probe_audio_bitrate", lambda _path: bitrate)

    assert convert.opus_bitrate_for(source) == expected


def test_convert_lossless_path_rejects_explicit_flac(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.flac")

    with pytest.raises(convert.AudmanError, match="compress flac"):
        convert.convert_lossless_path(source)
    assert source.exists()


def test_convert_lossless_single_rejects_flac(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.flac")

    with pytest.raises(convert.AudmanError, match="compress flac"):
        convert.convert_lossless_single(source, tmp_path / "out.flac")


def test_convert_lossless_path_converts_wav_and_backs_up(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    backup_base: Path,
) -> None:
    source = write_file(tmp_path / "source.wav")
    monkeypatch.setattr(convert, "_encode_flac", fake_encode_flac)

    result = convert.convert_lossless_path(source)

    output = tmp_path / "source.flac"
    backup_dir = backup_base / "20260831-161755-source.wav"
    backup = backup_dir / "source.wav"
    assert result.results == [
        convert.ConversionResult(source.resolve(), output, "converted")
    ]
    assert result.backup_dir == backup_dir
    assert output.read_text(encoding="utf-8") == "flac:source.wav"
    assert backup.read_text(encoding="utf-8") == "audio"
    assert not source.exists()


def test_convert_lossless_path_converts_alac_m4a(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.m4a")
    monkeypatch.setattr(convert, "_probe_codec", lambda _path: "alac")
    monkeypatch.setattr(convert, "_encode_flac", fake_encode_flac)

    result = convert.convert_lossless_path(source)

    assert result.results[0].action == "converted"
    assert (tmp_path / "source.flac").exists()


def test_convert_lossless_path_rejects_explicit_aac_m4a(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.m4a")
    monkeypatch.setattr(convert, "_probe_codec", lambda _path: "aac")

    with pytest.raises(convert.AudmanError, match="not a supported lossless file"):
        convert.convert_lossless_path(source)
    assert source.exists()


def test_convert_lossy_single_writes_output_without_backup(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.mp3")
    output = tmp_path / "target.opus"
    monkeypatch.setattr(convert, "_probe_audio_bitrate", lambda _path: 320_000)
    monkeypatch.setattr(convert, "_encode_opus", fake_encode_opus)

    result = convert.convert_lossy_single(source, output)

    assert result == convert.ConversionResult(source.resolve(), output, "converted")
    assert output.read_text(encoding="utf-8") == "opus:192k:source.mp3"
    assert source.exists()


def test_single_requires_force_to_replace_existing_output(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.wav")
    output = write_file(tmp_path / "target.opus", "old")
    encoded = []

    def encode(source: Path, dest: Path, bitrate: str) -> None:
        encoded.append((source, dest, bitrate))
        fake_encode_opus(source, dest, bitrate)

    monkeypatch.setattr(convert, "_encode_opus", encode)

    with pytest.raises(convert.AudmanError, match="already exists"):
        convert.convert_lossy_single(source, output)

    assert encoded == []
    assert output.read_text(encoding="utf-8") == "old"

    convert.convert_lossy_single(source, output, force=True)

    assert output.read_text(encoding="utf-8") == "opus:192k:source.wav"
    assert source.exists()


def test_failed_forced_single_preserves_existing_output(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.wav")
    output = write_file(tmp_path / "target.opus", "old")

    def fail_encode(_source: Path, dest: Path, _bitrate: str) -> None:
        dest.write_text("partial", encoding="utf-8")
        raise convert.AudmanError("encode failed")

    monkeypatch.setattr(convert, "_encode_opus", fail_encode)

    with pytest.raises(convert.AudmanError, match="encode failed"):
        convert.convert_lossy_single(source, output, force=True)

    assert output.read_text(encoding="utf-8") == "old"
    assert source.exists()
    assert not list(tmp_path.glob(".audman-*"))


def test_single_rejects_source_changes_during_conversion(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.wav", "original")
    output = tmp_path / "target.opus"

    def encode(_source: Path, dest: Path, _bitrate: str) -> None:
        dest.write_text("converted", encoding="utf-8")
        source.write_text("replaced", encoding="utf-8")

    monkeypatch.setattr(convert, "_encode_opus", encode)

    with pytest.raises(convert.AudmanError, match="input file changed"):
        convert.convert_lossy_single(source, output)

    assert source.read_text(encoding="utf-8") == "replaced"
    assert not output.exists()


def test_forced_single_rejects_destination_changes_during_conversion(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.wav")
    output = write_file(tmp_path / "target.opus", "old")

    def encode(_source: Path, dest: Path, _bitrate: str) -> None:
        dest.write_text("converted", encoding="utf-8")
        output.write_text("replaced", encoding="utf-8")

    monkeypatch.setattr(convert, "_encode_opus", encode)

    with pytest.raises(convert.AudmanError, match="output file changed"):
        convert.convert_lossy_single(source, output, force=True)

    assert output.read_text(encoding="utf-8") == "replaced"


def test_single_encodes_in_temporary_directory(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.wav")
    output = tmp_path / "target.opus"
    staged_paths = []

    def encode(source: Path, dest: Path, bitrate: str) -> None:
        staged_paths.append(dest)
        assert dest.parent.parent == output.parent
        assert dest.name == output.name
        fake_encode_opus(source, dest, bitrate)

    monkeypatch.setattr(convert, "_encode_opus", encode)

    convert.convert_lossy_single(source, output)

    assert output.exists()
    assert len(staged_paths) == 1
    assert not staged_paths[0].parent.exists()


@pytest.mark.parametrize(
    "suffix",
    [".wav", ".wave", ".aif", ".aifc", ".aiff", ".alac", ".caf", ".m4a"],
)
def test_lossless_apple_formats_are_valid_opus_inputs(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    suffix: str,
) -> None:
    source = write_file(tmp_path / f"source{suffix}")
    output = tmp_path / "target.opus"
    monkeypatch.setattr(convert, "_probe_codec", lambda _path: "alac")
    monkeypatch.setattr(convert, "_encode_opus", fake_encode_opus)

    convert.convert_lossy_single(source, output)

    assert output.read_text(encoding="utf-8") == f"opus:192k:source{suffix}"


def test_convert_lossy_path_converts_and_backs_up(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    backup_base: Path,
) -> None:
    source = write_file(tmp_path / "source.mp3")
    monkeypatch.setattr(convert, "_probe_audio_bitrate", lambda _path: 128_000)
    monkeypatch.setattr(convert, "_encode_opus", fake_encode_opus)

    result = convert.convert_lossy_path(source)

    output = tmp_path / "source.opus"
    backup_dir = backup_base / "20260831-161755-source.mp3"
    backup = backup_dir / "source.mp3"
    assert result.results == [
        convert.ConversionResult(source.resolve(), output, "converted")
    ]
    assert result.backup_dir == backup_dir
    assert output.read_text(encoding="utf-8") == "opus:96k:source.mp3"
    assert backup.exists()
    assert not source.exists()


def test_forced_path_conversion_backs_up_source_and_old_output(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    backup_base: Path,
) -> None:
    source = write_file(tmp_path / "source.wav", "source")
    output = write_file(tmp_path / "source.opus", "old output")
    monkeypatch.setattr(convert, "_encode_opus", fake_encode_opus)

    result = convert.convert_lossy_path(source, force=True)

    backup_dir = backup_base / "20260831-161755-source.wav"
    assert result.backup_dir == backup_dir
    assert (backup_dir / "source.wav").read_text(encoding="utf-8") == "source"
    assert (backup_dir / "source.opus").read_text(encoding="utf-8") == "old output"
    assert output.read_text(encoding="utf-8") == "opus:192k:source.wav"


def test_compress_flac_path_replaces_source_and_backs_up(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    backup_base: Path,
) -> None:
    source = write_file(tmp_path / "source.flac")
    monkeypatch.setattr(convert, "_encode_flac", fake_encode_flac)

    result = convert.compress_flac_path(source)

    backup_dir = backup_base / "20260831-161755-source.flac"
    backup = backup_dir / "source.flac"
    assert result.results == [
        convert.ConversionResult(source.resolve(), source.resolve(), "compressed")
    ]
    assert result.backup_dir == backup_dir
    assert source.read_text(encoding="utf-8") == "flac:source.flac"
    assert backup.read_text(encoding="utf-8") == "audio"


def test_directory_backup_preserves_relative_structure(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    backup_base: Path,
) -> None:
    target = tmp_path / "Qobuz Import"
    source = write_file(target / "Artist" / "Album" / "track.flac")
    monkeypatch.setattr(convert, "_encode_flac", fake_encode_flac)

    result = convert.compress_flac_path(target)

    backup_dir = backup_base / "20260831-161755-Qobuz-Import"
    backup = backup_dir / "Artist" / "Album" / "track.flac"
    assert result.backup_dir == backup_dir
    assert backup.read_text(encoding="utf-8") == "audio"
    assert source.read_text(encoding="utf-8") == "flac:track.flac"


def test_no_backup_removes_source_without_creating_backup(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    backup_base: Path,
) -> None:
    source = write_file(tmp_path / "source.mp3")
    monkeypatch.setattr(convert, "_probe_audio_bitrate", lambda _path: 128_000)
    monkeypatch.setattr(convert, "_encode_opus", fake_encode_opus)

    result = convert.convert_lossy_path(source, backup=False)

    assert result.backup_dir is None
    assert not source.exists()
    assert not backup_base.exists()


def test_no_backup_in_place_compression_replaces_without_predelete(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.flac", "original")
    monkeypatch.setattr(convert, "_encode_flac", fake_encode_flac)
    real_replace = convert.os.replace
    source_existed_during_replace = []

    def replace(staged: Path, output: Path) -> None:
        source_existed_during_replace.append(source.exists())
        real_replace(staged, output)

    monkeypatch.setattr(convert.os, "replace", replace)

    convert.compress_flac_path(source, backup=False)

    assert source_existed_during_replace == [True]
    assert source.read_text(encoding="utf-8") == "flac:source.flac"


def test_failed_install_restores_backed_up_source(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.flac", "original")
    monkeypatch.setattr(convert, "_encode_flac", fake_encode_flac)
    monkeypatch.setattr(
        convert,
        "_install_staged",
        lambda *_args, **_kwargs: (_ for _ in ()).throw(
            convert.AudmanError("install failed")
        ),
    )

    with pytest.raises(convert.AudmanError, match="install failed"):
        convert.compress_flac_path(source)

    assert source.read_text(encoding="utf-8") == "original"


def test_interrupted_install_restores_backed_up_source(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.flac", "original")
    monkeypatch.setattr(convert, "_encode_flac", fake_encode_flac)
    monkeypatch.setattr(
        convert,
        "_install_staged",
        lambda *_args, **_kwargs: (_ for _ in ()).throw(KeyboardInterrupt()),
    )

    with pytest.raises(KeyboardInterrupt):
        convert.compress_flac_path(source)

    assert source.read_text(encoding="utf-8") == "original"


def test_matching_files_skips_legacy_backup_directory(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.mp3")
    write_file(tmp_path / convert.LEGACY_BACKUP_DIR_NAME / "backup.mp3")

    assert convert._matching_files(tmp_path, {".mp3"}) == [source]


def test_matching_files_skips_state_backups_and_staging_directories(
    tmp_path: Path,
    backup_base: Path,
) -> None:
    source = write_file(tmp_path / "source.mp3")
    write_file(backup_base / "old" / "backup.mp3")
    write_file(tmp_path / ".audman-active" / "staged.mp3")

    assert convert._matching_files(tmp_path, {".mp3"}) == [source]


def test_directory_input_rejects_symlinks(tmp_path: Path) -> None:
    target = write_file(tmp_path / "target.mp3")
    (tmp_path / "link.mp3").symlink_to(target)

    with pytest.raises(convert.AudmanError, match="symbolic links"):
        convert.convert_lossy_path(tmp_path)


def test_single_rejects_input_and_output_symlinks(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.wav")
    source_link = tmp_path / "source-link.wav"
    source_link.symlink_to(source)
    output_target = write_file(tmp_path / "output-target.opus", "old")
    output_link = tmp_path / "output.opus"
    output_link.symlink_to(output_target)

    with pytest.raises(convert.AudmanError, match="symbolic links"):
        convert.convert_lossy_single(source_link, tmp_path / "new.opus")
    with pytest.raises(convert.AudmanError, match="symbolic links"):
        convert.convert_lossy_single(source, output_link, force=True)

    assert output_target.read_text(encoding="utf-8") == "old"


def test_single_validates_output_path(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.wav")

    with pytest.raises(convert.AudmanError, match="must use the .opus extension"):
        convert.convert_lossy_single(source, tmp_path / "output.flac")
    with pytest.raises(convert.AudmanError, match="must be different"):
        convert.convert_lossy_single(source, source)


def test_single_rejects_hardlink_aliases(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.flac")
    output = tmp_path / "output.flac"
    output.hardlink_to(source)

    with pytest.raises(convert.AudmanError, match="must be different"):
        convert.compress_flac_single(source, output, force=True)


def test_explicit_unsupported_input_is_an_error(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.txt")

    with pytest.raises(convert.AudmanError, match="unsupported input type"):
        convert.convert_lossy_path(source)


def test_duplicate_outputs_fail_before_encoding(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    write_file(tmp_path / "track.wav")
    write_file(tmp_path / "track.aiff")
    encoded = []
    monkeypatch.setattr(convert, "_encode_flac", lambda *_args: encoded.append(True))

    with pytest.raises(convert.AudmanError, match="same output"):
        convert.convert_lossless_path(tmp_path)

    assert encoded == []


def test_case_only_duplicate_outputs_fail_before_encoding(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    write_file(tmp_path / "Track.wav")
    write_file(tmp_path / "track.aiff")
    encoded = []
    monkeypatch.setattr(convert, "_encode_flac", lambda *_args: encoded.append(True))

    with pytest.raises(convert.AudmanError, match="same output"):
        convert.convert_lossless_path(tmp_path)

    assert encoded == []


def test_unicode_normalization_duplicate_outputs_fail_before_encoding(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    write_file(tmp_path / "Caf\u00e9.wav")
    write_file(tmp_path / "Cafe\u0301.aiff")
    encoded = []
    monkeypatch.setattr(convert, "_encode_flac", lambda *_args: encoded.append(True))

    with pytest.raises(convert.AudmanError, match="same output"):
        convert.convert_lossless_path(tmp_path)

    assert encoded == []


def test_directory_conversion_uses_requested_jobs(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    seen_workers = []
    write_file(tmp_path / "a.mp3")
    write_file(tmp_path / "b.mp3")

    class FakeFuture:
        def __init__(self, result) -> None:
            self.value = result

        def result(self):
            return self.value

        def cancel(self) -> None:
            return None

    class FakeExecutor:
        def __init__(self, max_workers: int) -> None:
            seen_workers.append(max_workers)

        def __enter__(self):
            return self

        def __exit__(self, exc_type, exc, tb) -> None:
            return None

        def submit(self, func, item):
            return FakeFuture(func(item))

    monkeypatch.setattr(convert, "ThreadPoolExecutor", FakeExecutor)
    monkeypatch.setattr(convert, "as_completed", list)
    monkeypatch.setattr(
        convert,
        "_convert_file",
        lambda path, mode, backup_plan, force, cancelled: convert.ConversionResult(
            path, None, mode
        ),
    )
    progress = []

    result = convert.convert_lossy_path(
        tmp_path, jobs=3, progress=lambda done, total: progress.append((done, total))
    )

    assert seen_workers == [3]
    assert [item.source.name for item in result.results] == ["a.mp3", "b.mp3"]
    assert progress == [(0, 2), (1, 2), (2, 2)]


def test_normalize_jobs_defaults_to_cpu_count(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(convert.os, "cpu_count", lambda: 7)

    assert convert._normalize_jobs(None) == 7


def test_normalize_jobs_minimum() -> None:
    assert convert._normalize_jobs(0) == 1


def test_flac_encoder_restores_embedded_artwork(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = tmp_path / "source.flac"
    output = tmp_path / "output.flac"
    picture = convert._new_picture(b"picture", "image/jpeg")
    commands = []
    written = []
    monkeypatch.setattr(convert, "_validate_streams", lambda _path: 1)
    monkeypatch.setattr(convert, "_embedded_pictures", lambda _path: [picture])
    monkeypatch.setattr(convert, "_flac_cuesheet", lambda _path: None)
    monkeypatch.setattr(convert, "_probe_chapters", lambda _path: [])
    monkeypatch.setattr(convert, "_flac_sample_args", lambda _path: [])
    monkeypatch.setattr(
        convert,
        "_run",
        lambda command, capture=False: commands.append(command),
    )
    monkeypatch.setattr(
        convert,
        "_write_flac_metadata",
        lambda path, pictures, cuesheet: written.append((path, pictures, cuesheet)),
    )

    convert._encode_flac(source, output)

    command = commands[0]
    assert "-vn" not in command
    assert [
        command[index + 1] for index, value in enumerate(command) if value == "-map"
    ] == ["0:a:0"]
    assert written == [(output, [picture], None)]


def test_opus_encoder_restores_embedded_artwork(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = tmp_path / "source.flac"
    output = tmp_path / "output.opus"
    picture = convert._new_picture(b"picture", "image/jpeg")
    commands = []
    written = []
    monkeypatch.setattr(convert, "_validate_streams", lambda _path: 1)
    monkeypatch.setattr(convert, "_embedded_pictures", lambda _path: [picture])
    monkeypatch.setattr(convert, "_flac_cuesheet", lambda _path: None)
    monkeypatch.setattr(convert, "_probe_chapters", lambda _path: [])
    monkeypatch.setattr(
        convert,
        "_run",
        lambda command, capture=False: commands.append(command),
    )
    monkeypatch.setattr(
        convert,
        "_write_opus_pictures",
        lambda path, pictures: written.append((path, pictures)),
    )

    convert._encode_opus(source, output, "192k")

    command = commands[0]
    assert "-vn" not in command
    assert [
        command[index + 1] for index, value in enumerate(command) if value == "-map"
    ] == ["0:a:0"]
    assert written == [(output, [picture])]


def test_stream_validation_accepts_artwork_and_rejects_other_streams(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = tmp_path / "source.flac"
    monkeypatch.setattr(
        convert,
        "_probe_streams",
        lambda _path: [
            {"index": 0, "codec_type": "audio", "disposition": {}},
            {
                "index": 1,
                "codec_type": "video",
                "disposition": {"attached_pic": 1},
            },
        ],
    )
    assert convert._validate_streams(source) == 1

    monkeypatch.setattr(
        convert,
        "_probe_streams",
        lambda _path: [
            {"index": 0, "codec_type": "audio", "disposition": {}},
            {"index": 1, "codec_type": "subtitle", "disposition": {}},
        ],
    )
    with pytest.raises(convert.AudmanError, match="cannot preserve subtitle stream"):
        convert._validate_streams(source)


def test_stream_validation_rejects_multiple_audio_streams(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = tmp_path / "source.flac"
    monkeypatch.setattr(
        convert,
        "_probe_streams",
        lambda _path: [
            {"index": 0, "codec_type": "audio"},
            {"index": 1, "codec_type": "audio"},
        ],
    )

    with pytest.raises(convert.AudmanError, match="exactly one audio stream"):
        convert._validate_streams(source)


def test_write_opus_pictures_uses_metadata_block_picture(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    output = tmp_path / "output.opus"
    picture = convert._new_picture(
        b"\xff\xd8\xffpicture",
        "image/jpeg",
        picture_type=3,
        description="Front",
    )
    instances = []

    class FakeOpus:
        def __init__(self, path: Path) -> None:
            self.path = path
            self.tags = {}
            self.saved = False
            instances.append(self)

        def add_tags(self) -> None:
            self.tags = {}

        def save(self) -> None:
            self.saved = True

    monkeypatch.setattr(convert, "OggOpus", FakeOpus)

    convert._write_opus_pictures(output, [picture])

    encoded = instances[0].tags["metadata_block_picture"][0]
    restored = convert.Picture(convert.base64.b64decode(encoded))
    assert restored.data == picture.data
    assert restored.mime == "image/jpeg"
    assert restored.type == 3
    assert restored.desc == "Front"
    assert instances[0].saved


def test_validate_output_checks_codec(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    output = write_file(tmp_path / "output.opus")
    monkeypatch.setattr(convert, "_probe_codec", lambda _path: "flac")

    with pytest.raises(convert.AudmanError, match="instead of opus"):
        VALIDATE_OUTPUT(output, "opus")


def test_validate_output_rejects_truncated_opus_duration(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.flac")
    output = write_file(tmp_path / "output.opus")
    monkeypatch.setattr(convert, "_probe_codec", lambda _path: "opus")
    monkeypatch.setattr(convert, "_decoded_audio_hash", lambda _path: "SHA256=value")
    monkeypatch.setattr(
        convert,
        "_probe_duration",
        lambda path: 2.0 if path == source else 1.0,
    )

    with pytest.raises(convert.AudmanError, match="duration differs"):
        VALIDATE_OUTPUT(output, "opus", source=source)


def test_real_conversion_preserves_embedded_artwork(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    cover = tmp_path / "cover.png"
    source = tmp_path / "source.flac"
    opus = tmp_path / "output.opus"
    flac = tmp_path / "output.flac"
    monkeypatch.setattr(convert, "_validate_output", VALIDATE_OUTPUT)
    monkeypatch.setattr(convert, "_probe_codec", PROBE_CODEC)

    subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-hide_banner",
            "-loglevel",
            "error",
            "-f",
            "lavfi",
            "-i",
            "color=c=red:s=32x32",
            "-frames:v",
            "1",
            str(cover),
        ],
        check=True,
    )
    subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-hide_banner",
            "-loglevel",
            "error",
            "-f",
            "lavfi",
            "-i",
            "sine=frequency=440:duration=0.1",
            "-i",
            str(cover),
            "-map",
            "0:a:0",
            "-map",
            "1:v:0",
            "-codec:a",
            "flac",
            "-codec:v",
            "copy",
            "-disposition:v",
            "attached_pic",
            str(source),
        ],
        check=True,
    )

    convert.convert_lossy_single(source, opus)

    cue = tmp_path / "source.cue"
    cue.write_text(
        'FILE "source.flac" WAVE\n  TRACK 01 AUDIO\n    INDEX 01 00:00:00\n',
        encoding="utf-8",
    )
    subprocess.run(
        ["metaflac", f"--import-cuesheet-from={cue}", str(source)],
        check=True,
    )
    convert.compress_flac_single(source, flac)

    assert convert._probe_codec(opus) == "opus"
    assert convert._probe_codec(flac) == "flac"
    assert convert._validate_streams(opus) == 1
    assert convert._validate_streams(flac) == 1
    assert len(convert._embedded_pictures(opus)) == 1
    assert len(convert._embedded_pictures(flac)) == 1
    assert convert._flac_cuesheet(flac) == convert._flac_cuesheet(source)


def test_real_flac_conversion_preserves_32_bit_pcm_and_rejects_float(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    pcm = tmp_path / "integer.wav"
    floating_point = tmp_path / "float.wav"
    output = tmp_path / "integer.flac"
    monkeypatch.setattr(convert, "_validate_output", VALIDATE_OUTPUT)
    monkeypatch.setattr(convert, "_probe_codec", PROBE_CODEC)

    for codec, path in [("pcm_s32le", pcm), ("pcm_f32le", floating_point)]:
        subprocess.run(
            [
                "ffmpeg",
                "-y",
                "-hide_banner",
                "-loglevel",
                "error",
                "-f",
                "lavfi",
                "-i",
                "sine=frequency=440:duration=0.1",
                "-codec:a",
                codec,
                str(path),
            ],
            check=True,
        )

    convert.convert_lossless_single(pcm, output)

    assert convert._probe_audio_info(output)["bits_per_raw_sample"] == "32"
    with pytest.raises(convert.AudmanError, match="floating-point audio"):
        convert.convert_lossless_single(floating_point, tmp_path / "float.flac")


def test_opus_conversion_rejects_flac_cuesheet(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = tmp_path / "source.flac"
    output = tmp_path / "output.opus"
    monkeypatch.setattr(convert, "_validate_streams", lambda _path: 0)
    monkeypatch.setattr(convert, "_embedded_pictures", lambda _path: [])
    monkeypatch.setattr(convert, "_flac_cuesheet", lambda _path: object())

    with pytest.raises(convert.AudmanError, match="cannot preserve chapters"):
        convert._encode_opus(source, output, "192k")


def test_flac_conversion_rejects_unrepresentable_chapters(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = tmp_path / "source.m4a"
    output = tmp_path / "output.flac"
    monkeypatch.setattr(convert, "_validate_streams", lambda _path: 0)
    monkeypatch.setattr(convert, "_embedded_pictures", lambda _path: [])
    monkeypatch.setattr(convert, "_flac_cuesheet", lambda _path: None)
    monkeypatch.setattr(convert, "_probe_chapters", lambda _path: [{}])

    with pytest.raises(convert.AudmanError, match="cannot preserve chapters"):
        convert._encode_flac(source, output)

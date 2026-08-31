from __future__ import annotations

from pathlib import Path

import pytest

from audman import convert


@pytest.fixture(autouse=True)
def backup_base(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    base = tmp_path / "cache" / "audman-backup"
    monkeypatch.setattr(convert, "_backup_base_dir", lambda: base)
    monkeypatch.setattr(convert, "_runtime_timestamp", lambda: "20260831-161755")
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


def test_convert_lossless_path_skips_flac(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.flac")

    result = convert.convert_lossless_path(source)

    assert result.results == [
        convert.ConversionResult(source.resolve(), None, "skipped")
    ]
    assert result.backup_dir is None
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


def test_convert_lossless_path_skips_aac_m4a(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.m4a")
    monkeypatch.setattr(convert, "_probe_codec", lambda _path: "aac")

    result = convert.convert_lossless_path(source)

    assert result.results == [
        convert.ConversionResult(source.resolve(), None, "skipped")
    ]
    assert result.backup_dir is None
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


def test_no_backup_removes_source_without_creating_cache(
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


def test_matching_files_skips_legacy_backup_directory(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.mp3")
    write_file(tmp_path / convert.LEGACY_BACKUP_DIR_NAME / "backup.mp3")

    assert convert._matching_files(tmp_path, {".mp3"}) == [source]


def test_directory_conversion_uses_requested_jobs(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    seen_workers = []
    write_file(tmp_path / "a.mp3")
    write_file(tmp_path / "b.mp3")

    class FakeExecutor:
        def __init__(self, max_workers: int) -> None:
            seen_workers.append(max_workers)

        def __enter__(self):
            return self

        def __exit__(self, exc_type, exc, tb) -> None:
            return None

        def map(self, func, items):
            return [func(item) for item in items]

    monkeypatch.setattr(convert, "ThreadPoolExecutor", FakeExecutor)
    monkeypatch.setattr(
        convert,
        "_convert_file",
        lambda path, mode, backup_plan: convert.ConversionResult(path, None, mode),
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

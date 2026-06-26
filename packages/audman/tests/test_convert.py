from __future__ import annotations

from pathlib import Path

import pytest

from audman import convert


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

    assert result == [convert.ConversionResult(source.resolve(), None, "skipped")]
    assert source.exists()


def test_convert_lossless_single_rejects_flac(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.flac")

    with pytest.raises(convert.AudmanError, match="compress flac"):
        convert.convert_lossless_single(source, tmp_path / "out.flac")


def test_convert_lossless_path_converts_wav_and_backs_up(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.wav")
    monkeypatch.setattr(convert, "_encode_flac", fake_encode_flac)

    result = convert.convert_lossless_path(source)

    output = tmp_path / "source.flac"
    backup = tmp_path / convert.BACKUP_DIR_NAME / "source.wav"
    assert result == [convert.ConversionResult(source.resolve(), output, "converted")]
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

    assert result[0].action == "converted"
    assert (tmp_path / "source.flac").exists()


def test_convert_lossless_path_skips_aac_m4a(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.m4a")
    monkeypatch.setattr(convert, "_probe_codec", lambda _path: "aac")

    result = convert.convert_lossless_path(source)

    assert result == [convert.ConversionResult(source.resolve(), None, "skipped")]
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
    assert not (tmp_path / convert.BACKUP_DIR_NAME).exists()


def test_convert_lossy_path_converts_and_backs_up(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.mp3")
    monkeypatch.setattr(convert, "_probe_audio_bitrate", lambda _path: 128_000)
    monkeypatch.setattr(convert, "_encode_opus", fake_encode_opus)

    result = convert.convert_lossy_path(source)

    output = tmp_path / "source.opus"
    backup = tmp_path / convert.BACKUP_DIR_NAME / "source.mp3"
    assert result == [convert.ConversionResult(source.resolve(), output, "converted")]
    assert output.read_text(encoding="utf-8") == "opus:96k:source.mp3"
    assert backup.exists()
    assert not source.exists()


def test_compress_flac_path_replaces_source_and_backs_up(
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    source = write_file(tmp_path / "source.flac")
    monkeypatch.setattr(convert, "_encode_flac", fake_encode_flac)

    result = convert.compress_flac_path(source)

    backup = tmp_path / convert.BACKUP_DIR_NAME / "source.flac"
    assert result == [convert.ConversionResult(source.resolve(), source.resolve(), "compressed")]
    assert source.read_text(encoding="utf-8") == "flac:source.flac"
    assert backup.read_text(encoding="utf-8") == "audio"


def test_matching_files_skips_backup_directory(tmp_path: Path) -> None:
    source = write_file(tmp_path / "source.mp3")
    write_file(tmp_path / convert.BACKUP_DIR_NAME / "backup.mp3")

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
        lambda path, mode, backup: convert.ConversionResult(path, None, mode),
    )

    result = convert.convert_lossy_path(tmp_path, jobs=3)

    assert seen_workers == [3]
    assert [item.source.name for item in result] == ["a.mp3", "b.mp3"]


def test_normalize_jobs_defaults_to_cpu_count(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(convert.os, "cpu_count", lambda: 7)

    assert convert._normalize_jobs(None) == 7


def test_normalize_jobs_minimum() -> None:
    assert convert._normalize_jobs(0) == 1

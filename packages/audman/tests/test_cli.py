from __future__ import annotations

from pathlib import Path

from typer.testing import CliRunner

from audman import cli, convert


runner = CliRunner()


def test_batch_uses_progress_and_summary_without_file_dump(
    tmp_path: Path, monkeypatch
) -> None:
    target = tmp_path / "Qobuz"
    target.mkdir()
    backup_dir = tmp_path / "cache" / "20260831-161755-Qobuz"

    def fake_compress(path, backup, force, jobs, progress):
        assert not force
        progress(0, 2)
        progress(1, 2)
        progress(2, 2)
        return convert.ConversionRun(
            [
                convert.ConversionResult(
                    path / "one.flac", path / "one.flac", "compressed"
                ),
                convert.ConversionResult(
                    path / "two.flac", path / "two.flac", "compressed"
                ),
            ],
            backup_dir,
        )

    monkeypatch.setattr(cli, "compress_flac_path", fake_compress)

    result = runner.invoke(cli.app, ["compress", "flac", str(target)])

    assert result.exit_code == 0
    assert "2/2" in result.output
    assert "Finished 2 files: 2 compressed." in result.output
    assert f"Backup: {backup_dir}" in result.output
    assert "compressed:" not in result.output
    assert "one.flac ->" not in result.output


def test_single_uses_progress_and_summary(tmp_path: Path, monkeypatch) -> None:
    source = tmp_path / "source.flac"
    output = tmp_path / "output.flac"

    monkeypatch.setattr(
        cli,
        "compress_flac_single",
        lambda input_file, output_file, force: convert.ConversionResult(
            input_file, output_file, "compressed"
        ),
    )

    result = runner.invoke(
        cli.app,
        [
            "compress",
            "flac",
            "--single",
            "--input-file",
            str(source),
            "--output-file",
            str(output),
        ],
    )

    assert result.exit_code == 0
    assert "1/1" in result.output
    assert "Finished 1 files: 1 compressed." in result.output
    assert "source.flac ->" not in result.output


def test_single_forwards_force(tmp_path: Path, monkeypatch) -> None:
    source = tmp_path / "source.flac"
    output = tmp_path / "output.opus"
    seen = []

    def fake_convert(input_file, output_file, force):
        seen.append((input_file, output_file, force))
        return convert.ConversionResult(input_file, output_file, "converted")

    monkeypatch.setattr(cli, "convert_lossy_single", fake_convert)

    result = runner.invoke(
        cli.app,
        [
            "convert",
            "lossy",
            "--single",
            "--input-file",
            str(source),
            "--output-file",
            str(output),
            "--force",
        ],
    )

    assert result.exit_code == 0
    assert seen == [(source, output, True)]


def test_path_forwards_force(tmp_path: Path, monkeypatch) -> None:
    source = tmp_path / "source.flac"
    seen = []

    def fake_convert(path, backup, force, jobs, progress):
        seen.append((path, backup, force, jobs))
        progress(0, 0)
        return convert.ConversionRun([], None)

    monkeypatch.setattr(cli, "convert_lossy_path", fake_convert)

    result = runner.invoke(
        cli.app,
        ["convert", "lossy", str(source), "--force", "--no-backup"],
    )

    assert result.exit_code == 0
    assert seen == [(source, False, True, None)]


def test_single_rejects_path_only_options(tmp_path: Path) -> None:
    source = tmp_path / "source.flac"
    output = tmp_path / "output.opus"

    result = runner.invoke(
        cli.app,
        [
            "convert",
            "lossy",
            "--single",
            "--input-file",
            str(source),
            "--output-file",
            str(output),
            "--no-backup",
        ],
    )

    assert result.exit_code == 1
    assert "--no-backup cannot be used with --single" in result.output


def test_unsupported_explicit_file_returns_error(tmp_path: Path) -> None:
    source = tmp_path / "source.txt"
    source.write_text("not audio", encoding="utf-8")

    result = runner.invoke(cli.app, ["convert", "lossy", str(source)])

    assert result.exit_code == 1
    assert "unsupported input type" in result.output

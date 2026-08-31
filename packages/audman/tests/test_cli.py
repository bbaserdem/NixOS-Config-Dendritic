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

    def fake_compress(path, backup, jobs, progress):
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
        lambda input_file, output_file: convert.ConversionResult(
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

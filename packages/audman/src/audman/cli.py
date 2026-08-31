from __future__ import annotations

from collections import Counter
from pathlib import Path
from typing import Annotated

import typer

from .convert import (
    AudmanError,
    ConversionRun,
    compress_flac_path,
    compress_flac_single,
    convert_lossless_path,
    convert_lossless_single,
    convert_lossy_path,
    convert_lossy_single,
)

app = typer.Typer(no_args_is_help=True)
convert_app = typer.Typer(no_args_is_help=True)
compress_app = typer.Typer(no_args_is_help=True)
app.add_typer(convert_app, name="convert")
app.add_typer(compress_app, name="compress")


@convert_app.command("lossless")
def lossless(
    input_path: Annotated[Path | None, typer.Argument()] = None,
    single: Annotated[bool, typer.Option("--single")] = False,
    input_file: Annotated[Path | None, typer.Option("--input-file")] = None,
    output_file: Annotated[Path | None, typer.Option("--output-file")] = None,
    no_backup: Annotated[bool, typer.Option("--no-backup")] = False,
    jobs: Annotated[int | None, typer.Option("--jobs", min=1)] = None,
) -> None:
    """Convert non-FLAC lossless files to maximally compressed FLAC."""
    try:
        if single:
            if input_file is None or output_file is None:
                raise AudmanError("--single requires --input-file and --output-file")
            _run_single(convert_lossless_single, input_file, output_file)
            return

        if input_path is None:
            raise AudmanError("input path is required unless --single is used")

        _run_path(convert_lossless_path, input_path, not no_backup, jobs)
    except AudmanError as exc:
        _exit_error(str(exc))


@convert_app.command("lossy")
def lossy(
    input_path: Annotated[Path | None, typer.Argument()] = None,
    single: Annotated[bool, typer.Option("--single")] = False,
    input_file: Annotated[Path | None, typer.Option("--input-file")] = None,
    output_file: Annotated[Path | None, typer.Option("--output-file")] = None,
    no_backup: Annotated[bool, typer.Option("--no-backup")] = False,
    jobs: Annotated[int | None, typer.Option("--jobs", min=1)] = None,
) -> None:
    """Convert supported files to Opus."""
    try:
        if single:
            if input_file is None or output_file is None:
                raise AudmanError("--single requires --input-file and --output-file")
            _run_single(convert_lossy_single, input_file, output_file)
            return

        if input_path is None:
            raise AudmanError("input path is required unless --single is used")

        _run_path(convert_lossy_path, input_path, not no_backup, jobs)
    except AudmanError as exc:
        _exit_error(str(exc))


@compress_app.command("flac")
def flac(
    input_path: Annotated[Path | None, typer.Argument()] = None,
    single: Annotated[bool, typer.Option("--single")] = False,
    input_file: Annotated[Path | None, typer.Option("--input-file")] = None,
    output_file: Annotated[Path | None, typer.Option("--output-file")] = None,
    no_backup: Annotated[bool, typer.Option("--no-backup")] = False,
    jobs: Annotated[int | None, typer.Option("--jobs", min=1)] = None,
) -> None:
    """Re-encode FLAC files with maximum compression."""
    try:
        if single:
            if input_file is None or output_file is None:
                raise AudmanError("--single requires --input-file and --output-file")
            _run_single(compress_flac_single, input_file, output_file)
            return

        if input_path is None:
            raise AudmanError("input path is required unless --single is used")

        _run_path(compress_flac_path, input_path, not no_backup, jobs)
    except AudmanError as exc:
        _exit_error(str(exc))


class _ProgressDisplay:
    width = 24

    def __init__(self) -> None:
        self.started = False

    def update(self, completed: int, total: int) -> None:
        ratio = completed / total if total else 0
        filled = int(self.width * ratio)
        bar = "#" * filled + "-" * (self.width - filled)
        typer.echo(f"\r[{bar}] {completed}/{total}", nl=False)
        self.started = True

    def finish(self) -> None:
        if self.started:
            typer.echo()
            self.started = False


def _run_path(operation, input_path: Path, backup: bool, jobs: int | None) -> None:
    progress = _ProgressDisplay()
    try:
        run = operation(
            input_path,
            backup=backup,
            jobs=jobs,
            progress=progress.update,
        )
    finally:
        progress.finish()
    _print_summary(run)


def _run_single(operation, input_file: Path, output_file: Path) -> None:
    progress = _ProgressDisplay()
    progress.update(0, 1)
    try:
        result = operation(input_file, output_file)
        progress.update(1, 1)
    finally:
        progress.finish()
    _print_summary(ConversionRun([result], None))


def _print_summary(run: ConversionRun) -> None:
    counts = Counter(result.action for result in run.results)
    details = ", ".join(f"{count} {action}" for action, count in counts.items())
    suffix = f": {details}" if details else ""
    typer.echo(f"Finished {len(run.results)} files{suffix}.")
    if run.backup_dir is not None:
        typer.echo(f"Backup: {run.backup_dir}")


def _exit_error(message: str) -> None:
    typer.secho(f"audman: {message}", fg=typer.colors.RED, err=True)
    raise typer.Exit(1)

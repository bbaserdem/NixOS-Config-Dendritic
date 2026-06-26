from __future__ import annotations

from pathlib import Path
from typing import Annotated

import typer

from .convert import (
    AudmanError,
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
            _print_result(convert_lossless_single(input_file, output_file))
            return

        if input_path is None:
            raise AudmanError("input path is required unless --single is used")

        for result in convert_lossless_path(
            input_path, backup=not no_backup, jobs=jobs
        ):
            _print_result(result)
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
            _print_result(convert_lossy_single(input_file, output_file))
            return

        if input_path is None:
            raise AudmanError("input path is required unless --single is used")

        for result in convert_lossy_path(input_path, backup=not no_backup, jobs=jobs):
            _print_result(result)
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
            _print_result(compress_flac_single(input_file, output_file))
            return

        if input_path is None:
            raise AudmanError("input path is required unless --single is used")

        for result in compress_flac_path(input_path, backup=not no_backup, jobs=jobs):
            _print_result(result)
    except AudmanError as exc:
        _exit_error(str(exc))


def _print_result(result) -> None:
    if result.output is None:
        typer.echo(f"{result.action}: {result.source}")
    else:
        typer.echo(f"{result.action}: {result.source} -> {result.output}")


def _exit_error(message: str) -> None:
    typer.secho(f"audman: {message}", fg=typer.colors.RED, err=True)
    raise typer.Exit(1)

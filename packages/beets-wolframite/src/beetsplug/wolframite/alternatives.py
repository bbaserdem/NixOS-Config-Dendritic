"""Playlist synchronization for beets-alternatives collections."""

from __future__ import annotations

import os
from pathlib import Path
from typing import TYPE_CHECKING

import confuse
from beets import config

if TYPE_CHECKING:
    from beets.library import Item, Library
    from beets.plugins import BeetsPlugin


PLAYLIST_SUFFIXES = {".m3u", ".m3u8"}


def sync_updated_collections(
    plugin: BeetsPlugin,
    lib: Library,
    collections: set[str],
) -> None:
    """Synchronize playlists for touched alternatives collections."""
    for collection in sorted(collections):
        count = sync_collection_playlists(lib, collection)
        plugin._log.info(
            "Synchronized {} playlist(s) for alternatives collection {}",
            count,
            collection,
        )


def sync_collection_playlists(lib: Library, collection: str) -> int:
    """Copy and rewrite playlists for one alternatives collection."""
    target_dir = _alternative_directory(lib, collection)
    source_dir = _playlist_dir(lib)
    relative_to = _playlist_relative_to(lib)
    item_by_path = _items_by_path(lib)

    synced_count = 0
    for source_playlist in _playlist_files(source_dir):
        target_playlist = target_dir / source_playlist.name
        entries = _translated_entries(
            source_playlist,
            relative_to,
            target_dir,
            item_by_path,
            collection,
        )

        if entries:
            target_playlist.parent.mkdir(parents=True, exist_ok=True)
            target_playlist.write_text("\n".join(entries) + "\n", encoding="utf-8")
            synced_count += 1
        elif target_playlist.exists():
            target_playlist.unlink()

    return synced_count


def _translated_entries(
    source_playlist: Path,
    relative_to: Path,
    target_dir: Path,
    item_by_path: dict[str, Item],
    collection: str,
) -> list[str]:
    entries = []

    for source_path in _read_playlist_entries(source_playlist, relative_to):
        item = item_by_path.get(_normalized_path(source_path))
        if item is None:
            continue

        target_path = _alternative_item_path(item, collection)
        if target_path is None or not target_path.exists():
            continue

        entries.append(os.path.relpath(target_path, target_dir))

    return entries


def _read_playlist_entries(path: Path, relative_to: Path) -> list[Path]:
    entries = []

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "://" in line:
            continue

        entry = Path(line).expanduser()
        if not entry.is_absolute():
            entry = relative_to / entry

        entries.append(entry)

    return entries


def _playlist_files(directory: Path) -> list[Path]:
    if not directory.exists():
        return []

    return sorted(
        path
        for path in directory.iterdir()
        if path.is_file() and path.suffix.lower() in PLAYLIST_SUFFIXES
    )


def _alternative_item_path(item: Item, collection: str) -> Path | None:
    path = item.get(f"alt.{collection}")
    if not path:
        return None

    return Path(os.fsdecode(path))


def _items_by_path(lib: Library) -> dict[str, Item]:
    return {_normalized_path(_path_from_beets(item.path)): item for item in lib.items()}


def _alternative_directory(lib: Library, collection: str) -> Path:
    configured = config["alternatives"][collection]["directory"].as_path()
    if configured.is_absolute():
        return configured

    return _path_from_beets(lib.directory) / configured


def _playlist_dir(lib: Library) -> Path:
    return (
        _config_filename("smartplaylist", "playlist_dir")
        or _config_filename("playlist", "playlist_dir")
        or _path_from_beets(lib.directory)
    )


def _playlist_relative_to(lib: Library) -> Path:
    return (
        _config_relative_to("smartplaylist", "relative_to", lib)
        or _config_relative_to("playlist", "relative_to", lib)
        or _path_from_beets(lib.directory)
    )


def _config_filename(section: str, key: str) -> Path | None:
    try:
        value = config[section][key].get()
    except confuse.NotFoundError:
        return None

    if not value:
        return None

    return Path(os.fsdecode(config[section][key].as_filename()))


def _config_relative_to(section: str, key: str, lib: Library) -> Path | None:
    try:
        value = config[section][key].get()
    except confuse.NotFoundError:
        return None

    if not value:
        return None

    if value == "library":
        return _path_from_beets(lib.directory)

    return Path(os.fsdecode(config[section][key].as_filename()))


def _path_from_beets(path) -> Path:
    return Path(os.fsdecode(path))


def _normalized_path(path: Path) -> str:
    return os.path.normcase(os.path.abspath(os.path.expanduser(os.fspath(path))))

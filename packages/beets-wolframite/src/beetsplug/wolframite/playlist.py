"""Playlist generation and ingestion from JSON."""

from __future__ import annotations

import os
from pathlib import Path
from typing import TYPE_CHECKING

import confuse
from beets import config
from beets.ui import Subcommand, UserError, should_write

from . import fields

if TYPE_CHECKING:
    from beets.library import Item, Library
    from beets.plugins import BeetsPlugin

ORDER_STEP = 100
PLAYLIST_SUFFIXES = {".m3u", ".m3u8"}


def commands(plugin: BeetsPlugin) -> list[Subcommand]:
    """Return beets CLI commands provided by this module."""
    command = Subcommand(
        "jsonpl",
        help="Manage JSON-backed playlists",
    )

    command.parser.add_option(
        "-w",
        "--write",
        action="store_true",
        dest="write",
        default=None,
        help="write changed playlist tags to files",
    )
    command.parser.add_option(
        "-W",
        "--nowrite",
        action="store_false",
        dest="write",
        help="do not write changed playlist tags to files",
    )

    command.func = lambda lib, opts, args: _dispatch(plugin, lib, opts, args)
    return [command]


def _dispatch(plugin: BeetsPlugin, lib: Library, opts, args: list[str]) -> None:
    if not args:
        raise UserError(
            "usage: beet jsonpl generate NAME... | generate-all | save PLAYLIST.m3u"
        )

    action = args[0]

    if action in {"generate", "gen"}:
        if len(args) < 2:
            raise UserError("usage: beet jsonpl generate NAME...")
        for name in args[1:]:
            path = generate_playlist(lib, name)
            plugin._log.info("Generated playlist {}", path)

    elif action in {"generate-all", "gen-all"}:
        paths = generate_all_playlists(lib)
        for path in paths:
            plugin._log.info("Generated playlist {}", path)

    elif action in {"save", "import"}:
        if len(args) != 2:
            raise UserError("usage: beet jsonpl save PLAYLIST.m3u")
        write = should_write(opts.write)
        changed = save_playlist(lib, Path(args[1]), write=write)
        plugin._log.info("Saved playlist tags for {} item(s)", changed)

    else:
        raise UserError(f"unknown jsonpl action: {action}")


def generate_playlist(lib: Library, name: str) -> Path:
    """Generate m3u playlist by playlist name without suffix."""
    name = _normalize_playlist_name(name)
    playlists = _collect_playlists(lib)

    if name not in playlists:
        raise UserError(f"playlist has no members: {name}")

    path = _playlist_path(lib, name)
    _write_m3u(lib, path, playlists[name])
    return path


def generate_all_playlists(lib: Library) -> list[Path]:
    """Generate all valid playlists found in playlist memberships."""
    playlists = _collect_playlists(lib)
    paths = []

    for name in sorted(playlists):
        path = _playlist_path(lib, name)
        _write_m3u(lib, path, playlists[name])
        paths.append(path)

    return paths


def save_playlist(lib: Library, playlist_path: Path, write: bool) -> int:
    """Ingest an m3u playlist into item playlist_memberships.

    The playlist name is derived from the m3u filename. Existing membership for
    that playlist is overwritten across the library.
    """
    playlist_path = playlist_path.expanduser()
    name = _playlist_name_from_path(playlist_path)
    relative_to = _relative_to(lib, playlist_path)

    paths = _read_m3u(playlist_path, relative_to)
    item_by_path = _items_by_path(lib)

    ordered_items = []
    missing_paths = []
    seen_ids = set()

    for path in paths:
        item = item_by_path.get(_normalized_path(path))
        if item is None:
            missing_paths.append(path)
            continue

        if item.id in seen_ids:
            continue

        seen_ids.add(item.id)
        ordered_items.append(item)

    if missing_paths:
        missing = "\n".join(f"  {path}" for path in missing_paths)
        raise UserError(f"playlist contains paths not in beets library:\n{missing}")

    desired_order = {
        item.id: index * ORDER_STEP for index, item in enumerate(ordered_items, start=1)
    }

    changed_items = []

    for item in lib.items():
        memberships = _memberships(item)
        old_memberships = dict(memberships)

        if name in memberships and item.id not in desired_order:
            del memberships[name]

        if item.id in desired_order:
            memberships[name] = desired_order[item.id]

        if memberships != old_memberships:
            _set_memberships(item, memberships)
            changed_items.append(item)

    _sync_changed_items(lib, changed_items, write)
    return len(changed_items)


def _collect_playlists(lib: Library) -> dict[str, list[tuple[int, Item]]]:
    playlists: dict[str, list[tuple[int, Item]]] = {}

    for item in lib.items():
        for name, order in _memberships(item).items():
            if not _is_valid_playlist_name(name):
                continue
            playlists.setdefault(name, []).append((order, item))

    for entries in playlists.values():
        entries.sort(key=lambda entry: (entry[0], *_item_sort_key(entry[1])))

    return playlists


def _write_m3u(lib: Library, path: Path, entries: list[tuple[int, Item]]) -> None:
    relative_to = _relative_to(lib, path)
    forward_slash = _forward_slash()

    lines = []
    for _, item in entries:
        item_path = _path_from_beets(item.path)
        playlist_entry = os.path.relpath(item_path, relative_to)
        if forward_slash:
            playlist_entry = playlist_entry.replace(os.sep, "/")
        lines.append(playlist_entry)

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def _read_m3u(path: Path, relative_to: Path) -> list[Path]:
    if path.suffix.lower() not in PLAYLIST_SUFFIXES:
        raise UserError(f"playlist path must end with .m3u or .m3u8: {path}")

    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except FileNotFoundError:
        raise UserError(f"playlist file does not exist: {path}") from None
    except IsADirectoryError:
        raise UserError(f"playlist path is a directory: {path}") from None
    except PermissionError:
        raise UserError(f"playlist file is not readable: {path}") from None
    except UnicodeDecodeError as exc:
        raise UserError(f"playlist file is not valid UTF-8: {path}: {exc}") from None
    except OSError as exc:
        raise UserError(f"could not read playlist file {path}: {exc}") from None

    entries = []

    for raw_line in lines:
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "://" in line:
            raise UserError(f"URL playlist entries are not supported: {line}")

        entry = Path(line).expanduser()
        if not entry.is_absolute():
            entry = relative_to / entry

        entries.append(entry)

    return entries


def _memberships(item: Item) -> dict[str, int]:
    try:
        return fields.loads_playlist_memberships(item.get("playlist_memberships"))
    except Exception as exc:
        raise UserError(f"invalid playlist_memberships on item {item.id}: {exc}")


def _set_memberships(item: Item, memberships: dict[str, int]) -> None:
    item["playlist_memberships"] = (
        fields.dumps_playlist_memberships(memberships) if memberships else ""
    )


def _sync_changed_items(lib: Library, items: list[Item], write: bool) -> None:
    seen = set()
    unique_items = []

    for item in items:
        if item.id in seen:
            continue
        seen.add(item.id)
        unique_items.append(item)

    with lib.transaction():
        for item in unique_items:
            item.store()

    if write:
        for item in unique_items:
            item.try_write()


def _items_by_path(lib: Library) -> dict[str, Item]:
    return {_normalized_path(_path_from_beets(item.path)): item for item in lib.items()}


def _playlist_path(lib: Library, name: str) -> Path:
    return _playlist_dir(lib) / f"{_normalize_playlist_name(name)}.m3u"


def _playlist_name_from_path(path: Path) -> str:
    if path.suffix.lower() not in PLAYLIST_SUFFIXES:
        raise UserError(f"playlist path must end with .m3u or .m3u8: {path}")

    return _normalize_playlist_name(path.stem)


def _normalize_playlist_name(name: str) -> str:
    name = name.removesuffix(".m3u").removesuffix(".m3u8")

    if not _is_valid_playlist_name(name):
        raise UserError(f"invalid playlist name: {name}")

    return name


def _is_valid_playlist_name(name: str) -> bool:
    if not name or name in {".", ".."}:
        return False

    separators = [os.sep]
    if os.altsep:
        separators.append(os.altsep)

    return not any(separator in name for separator in separators)


def _playlist_dir(lib: Library) -> Path:
    return (
        _config_filename("smartplaylist", "playlist_dir")
        or _config_filename("playlist", "playlist_dir")
        or _path_from_beets(lib.directory)
    )


def _relative_to(lib: Library, playlist_path: Path) -> Path:
    return (
        _config_relative_to("smartplaylist", "relative_to", lib, playlist_path)
        or _config_relative_to("playlist", "relative_to", lib, playlist_path)
        or _path_from_beets(lib.directory)
    )


def _forward_slash() -> bool:
    smart = _config_bool("smartplaylist", "forward_slash")
    if smart is not None:
        return smart

    playlist = _config_bool("playlist", "forward_slash")
    if playlist is not None:
        return playlist

    return False


def _config_filename(section: str, key: str) -> Path | None:
    try:
        value = config[section][key].get()
    except confuse.NotFoundError:
        return None

    if not value:
        return None

    return Path(os.fsdecode(config[section][key].as_filename()))


def _config_relative_to(
    section: str,
    key: str,
    lib: Library,
    playlist_path: Path,
) -> Path | None:
    try:
        value = config[section][key].get()
    except confuse.NotFoundError:
        return None

    if not value:
        return None

    if value == "library":
        return _path_from_beets(lib.directory)

    if value == "playlist":
        return playlist_path.parent

    return Path(os.fsdecode(config[section][key].as_filename()))


def _config_bool(section: str, key: str) -> bool | None:
    try:
        return config[section][key].get(bool)
    except confuse.NotFoundError:
        return None


def _path_from_beets(path) -> Path:
    return Path(os.fsdecode(path))


def _normalized_path(path: Path) -> str:
    return os.path.normcase(os.path.abspath(os.path.expanduser(os.fspath(path))))


def _item_sort_key(item: Item) -> tuple[str, str, int, int, str]:
    return (
        str(item.get("albumartist", "")).lower(),
        str(item.get("album", "")).lower(),
        int(item.get("disc", 0) or 0),
        int(item.get("track", 0) or 0),
        str(item.get("title", "")).lower(),
    )

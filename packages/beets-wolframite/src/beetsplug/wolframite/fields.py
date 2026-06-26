"""Custom database and media fields."""

from __future__ import annotations

import json
from collections.abc import Mapping
from typing import Any

import mediafile
from beets import library, ui
from beets.dbcore import types
from beets.library import Album
from beets.plugins import BeetsPlugin
from beets.ui import UserError
from beets.util import functemplate

from . import rating


def mp4_key(key: str) -> str:
    """Return iTunes-style MP4 freeform atom key."""
    return f"----:com.apple.iTunes:{key}"


def text_media_field(description: str, key: str) -> mediafile.MediaField:
    """Create a cross-format custom text tag."""
    return mediafile.MediaField(
        mediafile.MP3DescStorageStyle(description),
        mediafile.MP4StorageStyle(mp4_key(key)),
        mediafile.StorageStyle(key),
    )


def bool_media_field(description: str, key: str) -> mediafile.MediaField:
    """Create a cross-format custom boolean tag stored as 1/0 text."""
    return mediafile.MediaField(
        mediafile.MP3DescStorageStyle(description),
        mediafile.MP4StorageStyle(mp4_key(key)),
        mediafile.StorageStyle(key),
        out_type=bool,
    )


def list_text_media_field(description: str, key: str) -> mediafile.ListMediaField:
    """Create a cross-format custom multi-value text tag."""
    return mediafile.ListMediaField(
        mediafile.MP3ListDescStorageStyle(description),
        mediafile.MP4ListStorageStyle(mp4_key(key)),
        mediafile.ListStorageStyle(key),
    )


MEDIA_FIELDS: Mapping[str, mediafile.MediaField] = {
    "collection": text_media_field(
        "Wolframite Collection",
        "WOLFRAMITE_COLLECTION",
    ),
    "lossy": bool_media_field(
        "Wolframite Lossy",
        "WOLFRAMITE_LOSSY",
    ),
    "mood": list_text_media_field(
        "Wolframite Mood",
        "WOLFRAMITE_MOOD",
    ),
    "introducer": text_media_field(
        "Wolframite Introducer",
        "WOLFRAMITE_INTRODUCER",
    ),
    "playlist_memberships": text_media_field(
        "Wolframite Playlist Memberships",
        "WOLFRAMITE_PLAYLIST_MEMBERSHIPS",
    ),
}

ALBUM_TYPES = {
    "collection": types.STRING,
    "lossy": types.BOOLEAN,
    "mood": types.MULTI_VALUE_DSV,
    "introducer": types.STRING,
}

ITEM_TYPES = {
    **ALBUM_TYPES,
    "playlist_memberships": types.STRING,
    "stars": types.INTEGER,
}


def register_media_fields(plugin: BeetsPlugin) -> None:
    """Register custom fields that should round-trip through media files."""
    for name, field in MEDIA_FIELDS.items():
        plugin.add_media_field(name, field)
        library.Item._media_tag_fields.add(name)

    # We want to load this dynamically to inject email field
    plugin.add_media_field("stars", rating.stars_media_field(rating.rating_owner()))
    library.Item._media_tag_fields.add("stars")


def loads_playlist_memberships(value: Any) -> dict[str, int]:
    """Parse playlist membership JSON from a beets field."""
    if not value:
        return {}

    if isinstance(value, dict):
        raw = value
    else:
        raw = json.loads(str(value))

    return {
        str(name): int(order)
        for name, order in raw.items()
        if str(name) and order is not None
    }


def dumps_playlist_memberships(value: Mapping[str, int]) -> str:
    """Serialize playlist memberships in stable form."""
    return json.dumps(
        {str(name): int(order) for name, order in value.items()},
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    )


def propagated_album_fields() -> set[str]:
    """Custom album fields that also exist on items."""
    return set(ALBUM_TYPES) & set(ITEM_TYPES)


def sync_album_fields_to_items(album: Album, changed_fields: set[str]) -> None:
    fields = changed_fields & propagated_album_fields()
    if not fields:
        return

    for item in album.items():
        dirty = set()

        for field in fields:
            value = album.get(field)
            if item.get(field, with_album=False) != value:
                item[field] = value
                dirty.add(field)

        if dirty:
            item.store(fields=dirty)


def commands():
    cmd = ui.Subcommand(
        "propagate",
        help="modify album fields and propagate matching item fields",
    )
    cmd.parser.add_option(
        "-y",
        "--yes",
        action="store_true",
        help="skip confirmation",
    )
    cmd.func = wmod_func
    return [cmd]


def parse_mod_args(args: list[str]) -> tuple[list[str], dict[str, str]]:
    mods = {}
    query = []

    for arg in args:
        if "=" in arg and ":" not in arg.split("=", 1)[0]:
            key, value = arg.split("=", 1)
            if key not in ALBUM_TYPES:
                raise UserError(f"not a user album field: {key}")
            mods[key] = value
        else:
            query.append(arg)

    if not mods:
        raise UserError("no album field assignments specified")

    return query, mods


def wmod_func(lib, opts, args):
    query, mods = parse_mod_args(args)
    albums = list(lib.albums(query))

    if not albums:
        raise UserError("No matching albums found.")

    templates = {key: functemplate.template(value) for key, value in mods.items()}

    changed_albums = []

    for album in albums:
        parsed = {
            key: album._parse(key, album.evaluate_template(templates[key]))
            for key in mods
        }

        changed = False
        for key, value in parsed.items():
            if album.get(key) != value:
                album[key] = value
                changed = True

        if changed:
            changed_albums.append((album, set(parsed)))

    if not changed_albums:
        ui.print_("No changes to make.")
        return

    ui.print_(f"Modifying {len(changed_albums)} albums.")

    if not opts.yes:
        if not ui.input_yn("Really modify albums and propagate fields?", False):
            return

    with lib.transaction():
        for album, changed_fields in changed_albums:
            album.store(fields=changed_fields, inherit=False)
            sync_album_fields_to_items(album, changed_fields)

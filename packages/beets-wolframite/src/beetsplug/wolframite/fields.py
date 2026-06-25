"""Custom database and media fields."""

from __future__ import annotations

import json
from collections.abc import Mapping
from typing import Any

import mediafile
from beets.dbcore import types
from beets.plugins import BeetsPlugin

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

    # We want to load this dynamically to inject email field
    plugin.add_media_field("stars", rating.stars_media_field(rating.rating_owner()))


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

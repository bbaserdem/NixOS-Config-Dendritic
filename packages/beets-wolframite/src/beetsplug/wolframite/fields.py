"""Custom database and media fields."""

from __future__ import annotations

from collections.abc import Mapping
from functools import wraps

import mediafile
from beets import library
from beets.dbcore import types
from beets.library import Album
from beets.plugins import BeetsPlugin


def mp4_key(key: str) -> str:
    """Return an iTunes-style MP4 freeform atom key."""
    return f"----:com.apple.iTunes:{key}"


def text_media_field(description: str, key: str) -> mediafile.MediaField:
    """Create a cross-format custom text tag."""
    return mediafile.MediaField(
        mediafile.MP3DescStorageStyle(description),
        mediafile.MP4StorageStyle(mp4_key(key)),
        mediafile.StorageStyle(key),
        mediafile.ASFStorageStyle(key),
    )


def list_text_media_field(description: str, key: str) -> mediafile.ListMediaField:
    """Create a cross-format custom multi-value text tag."""
    return mediafile.ListMediaField(
        mediafile.MP3ListDescStorageStyle(description, split_v23=True),
        mediafile.MP4ListStorageStyle(mp4_key(key)),
        mediafile.ListStorageStyle(key),
        mediafile.ASFStorageStyle(key),
    )


MEDIA_FIELDS: Mapping[str, mediafile.MediaField] = {
    "collection": text_media_field(
        "Wolframite Collection",
        "WOLFRAMITE_COLLECTION",
    ),
    "mood": list_text_media_field(
        "Wolframite Mood",
        "WOLFRAMITE_MOOD",
    ),
    "introducer": text_media_field(
        "Wolframite Introducer",
        "WOLFRAMITE_INTRODUCER",
    ),
}

ALBUM_TYPES = {
    "collection": types.STRING,
    "lossy": types.BOOLEAN,
    "mood": types.MULTI_VALUE_DSV,
    "introducer": types.STRING,
}

ITEM_TYPES = dict(ALBUM_TYPES)


def register_media_fields(plugin: BeetsPlugin) -> None:
    """Register fields that round-trip through media files."""
    for name, field in MEDIA_FIELDS.items():
        plugin.add_media_field(name, field)
        library.Item._media_tag_fields.add(name)


def install_item_store_compatibility() -> None:
    """Keep partial stores from treating flexible fields as SQL columns."""
    original_store = library.Item.store
    if getattr(original_store, "_wolframite_flexible_fields", False):
        return

    @wraps(original_store)
    def store(item, fields=None) -> None:
        if fields is not None:
            fields = set(fields) - set(ITEM_TYPES)
        original_store(item, fields)

    setattr(store, "_wolframite_flexible_fields", True)
    setattr(library.Item, "store", store)


def sync_item_fields_to_album(album: Album) -> set[str]:
    """Rebuild album copies from unanimous item values."""
    items = list(album.items())
    if not items:
        return set()

    changed = set()
    for field in ALBUM_TYPES:
        values = [item.get(field, with_album=False) for item in items]
        value = values[0] if all(current == values[0] for current in values) else None
        if album.get(field) != value:
            album[field] = value
            changed.add(field)

    if changed:
        album.store(inherit=False)
    return changed

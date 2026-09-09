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


def install_store_compatibility() -> None:
    """Make partial stores select only the requested custom fields."""
    _install_item_store_compatibility()
    _install_album_store_compatibility()


def _install_item_store_compatibility() -> None:
    original_store = library.Item.store
    if getattr(original_store, "_wolframite_flexible_fields", False):
        return

    @wraps(original_store)
    def store(item, fields=None) -> None:
        if fields is None:
            original_store(item)
            return

        requested = set(fields)
        deferred = (set(item._dirty) & set(ITEM_TYPES)) - requested
        item._dirty.difference_update(deferred)
        try:
            original_store(item, requested - set(ITEM_TYPES))
        finally:
            item._dirty.update(deferred)

    setattr(store, "_wolframite_flexible_fields", True)
    setattr(library.Item, "store", store)


def _install_album_store_compatibility() -> None:
    original_store = library.Album.store
    if getattr(original_store, "_wolframite_flexible_fields", False):
        return

    @wraps(original_store)
    def store(album, fields=None, inherit=True) -> None:
        if fields is None:
            original_store(album, inherit=inherit)
            return

        requested = set(fields)
        deferred = (set(album._dirty) & set(ALBUM_TYPES)) - requested
        album._dirty.difference_update(deferred)
        try:
            original_store(
                album,
                requested - set(ALBUM_TYPES),
                inherit=inherit,
            )
        finally:
            album._dirty.update(deferred)

    setattr(store, "_wolframite_flexible_fields", True)
    setattr(library.Album, "store", store)


def sync_item_fields_to_album(album: Album) -> set[str]:
    """Rebuild album copies from unanimous item values."""
    items = list(album.items())
    if not items:
        return set()

    changed = set()
    for field in ALBUM_TYPES:
        values = [item.get(field, with_album=False) for item in items]
        if field == "mood":
            values = [sorted(value or []) for value in values]
        unanimous = all(current == values[0] for current in values)
        value = values[0] if unanimous else None
        null = ALBUM_TYPES[field].null

        if value is None or value == null:
            if field in album:
                del album[field]
                changed.add(field)
        elif album.get(field) != value:
            album[field] = value
            changed.add(field)

    if changed:
        album.store(inherit=False)
    return changed

from __future__ import annotations

from beets import config
from beets.dbcore import types
from beets.library import Item, Library

from beetsplug.wolframite import fields


def test_mood_is_multivalue_on_items_and_albums() -> None:
    assert fields.ALBUM_TYPES["mood"] is types.MULTI_VALUE_DSV
    assert fields.ITEM_TYPES["mood"] is types.MULTI_VALUE_DSV


def test_lossy_is_database_only() -> None:
    assert fields.ALBUM_TYPES["lossy"] is types.BOOLEAN
    assert fields.ITEM_TYPES["lossy"] is types.BOOLEAN
    assert "lossy" not in fields.MEDIA_FIELDS


def test_media_fields_include_only_synced_metadata() -> None:
    assert set(fields.MEDIA_FIELDS) == {
        "collection",
        "mood",
        "introducer",
    }


def test_mood_mp3_field_splits_id3v23_values() -> None:
    mood = fields.MEDIA_FIELDS["mood"]
    mp3_style = next(
        style
        for style in mood._styles
        if isinstance(style, fields.mediafile.MP3ListDescStorageStyle)
    )
    assert mp3_style.split_v23


def test_album_fields_rebuild_from_items(tmp_path) -> None:
    config.add(
        {
            "timeout": 5.0,
            "create_backup_before_migrations": False,
            "replace": {},
            "sort_item": [],
            "sort_album": [],
        }
    )
    item = Item(path=tmp_path / "track.flac", collection="Archive")
    library = Library(
        path=tmp_path / "library.db",
        directory=str(tmp_path / "music"),
    )
    album = library.add_album([item])

    changed = fields.sync_item_fields_to_album(album)

    assert "collection" in changed
    assert album.get("collection") == "Archive"

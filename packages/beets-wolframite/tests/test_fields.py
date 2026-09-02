from __future__ import annotations

import json

import pytest
from beets import config
from beets.dbcore import types
from beets.importer import tasks
from beets.library import Item, Library
from beets.ui import UserError

from beetsplug.wolframite import fields


def test_mood_is_multivalue_album_field() -> None:
    assert fields.ALBUM_TYPES["mood"] is types.MULTI_VALUE_DSV


def test_mood_is_multivalue_item_field() -> None:
    assert fields.ITEM_TYPES["mood"] is types.MULTI_VALUE_DSV


def test_playlist_memberships_is_item_only() -> None:
    assert "playlist_memberships" in fields.ITEM_TYPES
    assert "playlist_memberships" not in fields.ALBUM_TYPES


def test_loads_empty_playlist_memberships() -> None:
    assert fields.loads_playlist_memberships(None) == {}
    assert fields.loads_playlist_memberships("") == {}
    assert fields.loads_playlist_memberships({}) == {}


def test_loads_playlist_memberships_from_json() -> None:
    raw = '{"Roadtrip":100,"Favorites":"250"}'
    assert fields.loads_playlist_memberships(raw) == {
        "Roadtrip": 100,
        "Favorites": 250,
    }


def test_loads_playlist_memberships_from_mapping() -> None:
    assert fields.loads_playlist_memberships({"Roadtrip": "100"}) == {
        "Roadtrip": 100,
    }


def test_dumps_playlist_memberships_stable_json() -> None:
    dumped = fields.dumps_playlist_memberships(
        {
            "Favorites": 250,
            "Roadtrip": 100,
        }
    )

    assert dumped == '{"Favorites":250,"Roadtrip":100}'
    assert json.loads(dumped) == {
        "Favorites": 250,
        "Roadtrip": 100,
    }


def test_stars_is_item_only() -> None:
    assert fields.ITEM_TYPES["stars"] is fields.STARS_TYPE
    assert "stars" not in fields.ALBUM_TYPES


@pytest.mark.parametrize(
    ("value", "expected"),
    [(-1, 0), (3, 3), (99, 5), ("invalid", 0)],
)
def test_stars_type_clamps_values(value, expected: int) -> None:
    assert fields.STARS_TYPE.normalize(value) == expected


def test_media_fields_include_expected_fields() -> None:
    assert set(fields.MEDIA_FIELDS) == {
        "collection",
        "lossy",
        "mood",
        "introducer",
        "playlist_memberships",
    }


def test_mood_mp3_field_splits_id3v23_values() -> None:
    mood = fields.MEDIA_FIELDS["mood"]
    mp3_style = next(
        style
        for style in mood._styles
        if isinstance(style, fields.mediafile.MP3ListDescStorageStyle)
    )
    assert mp3_style.split_v23


def test_album_to_item_sync_repairs_drift(tmp_path) -> None:
    config.add(
        {
            "timeout": 5.0,
            "create_backup_before_migrations": False,
            "replace": {},
            "sort_item": [],
            "sort_album": [],
        }
    )
    library = Library(
        path=tmp_path / "library.db",
        directory=str(tmp_path / "music"),
    )
    item = Item(path=tmp_path / "track.flac", title="Track")
    item["collection"] = "Other"
    album = library.add_album([item])
    album["collection"] = "Archive"
    album.store(inherit=False)

    changed = fields.sync_album_fields_to_items(album, {"collection"})

    assert len(changed) == 1
    stored_item = library.items().get()
    assert stored_item is not None
    assert stored_item.get("collection", with_album=False) == "Archive"


def test_custom_fields_replace_stale_values_on_reimport() -> None:
    fields.install_reimport_fresh_fields()

    assert set(fields.ITEM_TYPES) <= set(tasks.REIMPORT_FRESH_FIELDS_ITEM)
    assert set(fields.ALBUM_TYPES) <= set(tasks.REIMPORT_FRESH_FIELDS_ALBUM)


def test_custom_field_deletion_keeps_authoritative_null() -> None:
    fields.install_file_authoritative_deletions()
    item = Item(collection="Archive")

    del item["collection"]

    assert item.get("collection", with_album=False) == ""
    assert "collection" in item.keys(with_album=False)


def test_write_batch_rolls_back_earlier_files(monkeypatch) -> None:
    item_a = Item(path="/a.flac", mood=["old-a"])
    item_b = Item(path="/b.flac", mood=["old-b"])
    snapshots = {
        item_a: {"mood": ["old-a"]},
        item_b: {"mood": ["old-b"]},
    }
    writes = []
    rollbacks = []
    monkeypatch.setattr(
        fields,
        "read_item_fields",
        lambda item, _selected: snapshots[item],
    )

    def write(item, _selected) -> None:
        writes.append(item)
        if item is item_b:
            raise UserError("write failed")

    monkeypatch.setattr(fields, "write_item_fields", write)
    monkeypatch.setattr(
        fields,
        "write_item_values",
        lambda item, values: rollbacks.append((item, values)),
    )

    with pytest.raises(UserError, match="write failed"):
        fields.write_item_fields_batch(
            [(item_a, {"mood"}), (item_b, {"mood"})]
        )

    assert writes == [item_a, item_b]
    assert rollbacks == [
        (item_b, {"mood": ["old-b"]}),
        (item_a, {"mood": ["old-a"]}),
    ]


def test_generic_write_preserves_unchanged_file_fields(monkeypatch) -> None:
    monkeypatch.setattr(
        Item,
        "_media_tag_fields",
        Item._media_tag_fields | {"mood", "stars"},
    )
    item = Item(path="/track.flac", mood=["stale"])
    item.clear_dirty()
    tags = {"mood": ["stale"], "stars": 2}
    monkeypatch.setattr(
        fields,
        "_read_media_fields",
        lambda _path, selected, _item_id: {
            field: {"mood": ["remote"], "stars": 5}[field]
            for field in selected
        },
    )

    fields._protect_write_tags(item, item.path, tags)

    assert tags == {"mood": ["remote"], "stars": 5}


def test_generic_write_keeps_explicitly_changed_field(monkeypatch) -> None:
    monkeypatch.setattr(
        Item,
        "_media_tag_fields",
        Item._media_tag_fields | {"mood"},
    )
    item = Item(path="/track.flac", mood=["old"])
    item.clear_dirty()
    item["mood"] = ["new"]
    tags = {"mood": ["new"]}
    monkeypatch.setattr(
        fields,
        "_read_media_fields",
        lambda _path, _selected, _item_id: {"mood": ["remote"]},
    )

    fields._protect_write_tags(item, item.path, tags)

    assert tags == {"mood": ["new"]}


def test_explicit_selective_write_overrides_matching_database_value(
    monkeypatch,
) -> None:
    monkeypatch.setattr(
        Item,
        "_media_tag_fields",
        Item._media_tag_fields | {"playlist_memberships"},
    )
    item = Item(path="/track.flac", playlist_memberships='{"Roadtrip":100}')
    item.clear_dirty()
    tags = {"playlist_memberships": '{"Roadtrip":100}'}
    key = fields._pending_key(item)
    fields._EXPLICIT_FILE_FIELDS[key] = {"playlist_memberships"}
    monkeypatch.setattr(
        fields,
        "_read_media_fields",
        lambda _path, _selected, _item_id: {"playlist_memberships": ""},
    )

    try:
        fields._protect_write_tags(item, item.path, tags)
    finally:
        fields._EXPLICIT_FILE_FIELDS.pop(key, None)

    assert tags == {"playlist_memberships": '{"Roadtrip":100}'}

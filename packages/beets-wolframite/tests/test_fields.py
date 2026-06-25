from __future__ import annotations

import json

from beets.dbcore import types

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
    assert fields.ITEM_TYPES["stars"] is types.INTEGER
    assert "stars" not in fields.ALBUM_TYPES


def test_media_fields_include_expected_fields() -> None:
    assert set(fields.MEDIA_FIELDS) == {
        "collection",
        "lossy",
        "mood",
        "introducer",
        "playlist_memberships",
    }

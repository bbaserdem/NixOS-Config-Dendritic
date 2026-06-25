from __future__ import annotations

from typing import Any, cast

import pytest
from beets.importer import ImportSession, ImportTask
from beets.library import Item
from beets.plugins import BeetsPlugin
from beets.ui import UserError

from beetsplug.wolframite import translate


class FakeMatch:
    def __init__(self, matching_ids: set[int]) -> None:
        self.matching_ids = matching_ids

    def match(self, item: FakeModel) -> bool:
        return item.id in self.matching_ids


class FakeModel:
    def __init__(self, model_id: int, **values: Any) -> None:
        self.id = model_id
        self.values = values
        self.store_calls = 0

    def get(self, key: str, default: Any = None) -> Any:
        return self.values.get(key, default)

    def __setitem__(self, key: str, value: Any) -> None:
        self.values[key] = value

    def set_parse(self, key: str, value: str) -> None:
        self.values[key] = value

    def store(self) -> None:
        self.store_calls += 1


class FakeTransaction:
    def __enter__(self) -> FakeTransaction:
        return self

    def __exit__(self, exc_type, exc, traceback) -> None:
        return None


class FakeLib:
    def transaction(self) -> FakeTransaction:
        return FakeTransaction()


class FakeSession:
    def __init__(self) -> None:
        self.lib = FakeLib()


class FakeTask:
    def __init__(
        self,
        items: list[FakeModel],
        album: FakeModel | None = None,
    ) -> None:
        self._items = items
        self.album = album
        self.is_album = album is not None

    def imported_items(self) -> list[FakeModel]:
        return self._items


class FakeConfigView:
    def __init__(self, value: list[dict[str, Any]]) -> None:
        self.value = value

    def get(self, _template) -> list[dict[str, Any]]:
        return self.value


class FakeConfig:
    def __init__(self, field_translations: list[dict[str, Any]]) -> None:
        self.field_translations = field_translations

    def __getitem__(self, key: str) -> FakeConfigView:
        assert key == "field_translations"
        return FakeConfigView(self.field_translations)


class FakePlugin:
    def __init__(self, field_translations: list[dict[str, Any]] | None = None) -> None:
        self.config = FakeConfig(field_translations or [])


def test_album_field_translation_propagates_to_all_items_and_album(monkeypatch) -> None:
    item_a = FakeModel(1, artist="Oh Sees", albumartist="Old")
    item_b = FakeModel(2, artist="Other", albumartist="Old")
    album = FakeModel(10, albumartist="Old")
    task = FakeTask([item_a, item_b], album=album)
    session = FakeSession()

    rule = translate.TranslationRule(
        match=FakeMatch({1}),
        replacements={"albumartist": "Osees"},
    )
    monkeypatch.setattr(translate, "_rules", lambda _plugin: [rule])

    translate.apply_field_translations(
        cast(BeetsPlugin, FakePlugin()),
        cast(ImportSession, session),
        cast(ImportTask, task),
    )

    assert item_a.get("albumartist") == "Osees"
    assert item_b.get("albumartist") == "Osees"
    assert album.get("albumartist") == "Osees"

    assert item_a.store_calls == 1
    assert item_b.store_calls == 1
    assert album.store_calls == 1


def test_item_only_translation_applies_only_to_matching_items(monkeypatch) -> None:
    item_a = FakeModel(1, artist="Oh Sees", title="Old A")
    item_b = FakeModel(2, artist="Other", title="Old B")
    album = FakeModel(10, album="Album")
    task = FakeTask([item_a, item_b], album=album)
    session = FakeSession()

    rule = translate.TranslationRule(
        match=FakeMatch({1}),
        replacements={"title": "Fixed"},
    )
    monkeypatch.setattr(translate, "_rules", lambda _plugin: [rule])

    translate.apply_field_translations(
        cast(BeetsPlugin, FakePlugin()),
        cast(ImportSession, session),
        cast(ImportTask, task),
    )

    assert item_a.get("title") == "Fixed"
    assert item_b.get("title") == "Old B"
    assert album.get("title") is None

    assert item_a.store_calls == 1
    assert item_b.store_calls == 0
    assert album.store_calls == 0


def test_list_translation_assigns_list_values(monkeypatch) -> None:
    item = FakeModel(1, artist="Artist", genres=[])
    album = FakeModel(10, genres=[])
    task = FakeTask([item], album=album)
    session = FakeSession()

    rule = translate.TranslationRule(
        match=FakeMatch({1}),
        replacements={"genres": ["rock", "psychedelic"]},
    )
    monkeypatch.setattr(translate, "_rules", lambda _plugin: [rule])

    translate.apply_field_translations(
        cast(BeetsPlugin, FakePlugin()),
        cast(ImportSession, session),
        cast(ImportTask, task),
    )

    assert item.get("genres") == ["rock", "psychedelic"]
    assert album.get("genres") == ["rock", "psychedelic"]


def test_no_rules_does_not_store_anything(monkeypatch) -> None:
    item = FakeModel(1, artist="Oh Sees", albumartist="Old")
    album = FakeModel(10, albumartist="Old")
    task = FakeTask([item], album=album)
    session = FakeSession()

    monkeypatch.setattr(translate, "_rules", lambda _plugin: [])

    translate.apply_field_translations(
        cast(BeetsPlugin, FakePlugin()),
        cast(ImportSession, session),
        cast(ImportTask, task),
    )

    assert item.get("albumartist") == "Old"
    assert album.get("albumartist") == "Old"
    assert item.store_calls == 0
    assert album.store_calls == 0


def test_validate_replacements_rejects_unknown_fields() -> None:
    with pytest.raises(UserError, match="invalid field"):
        translate._validate_replacements({"not_a_real_field": "value"})


def test_rules_parse_config_and_match_items() -> None:
    plugin = FakePlugin(
        [
            {
                "match": 'artist:"Oh Sees"',
                "replacements": {
                    "albumartist": "Osees",
                },
            }
        ]
    )

    rules = translate._rules(cast(BeetsPlugin, plugin))

    assert len(rules) == 1
    assert rules[0].replacements == {"albumartist": "Osees"}

    matching_item = Item(artist="Oh Sees")
    nonmatching_item = Item(artist="Other")

    assert rules[0].match.match(matching_item)
    assert not rules[0].match.match(nonmatching_item)

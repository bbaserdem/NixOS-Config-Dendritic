from __future__ import annotations

from types import SimpleNamespace
from typing import Any, cast

import pytest
from beets import config
from beets.importer import ImportSession, ImportTask, actions
from beets.library import Item
from beets.plugins import BeetsPlugin
from beets.ui import UserError

from beetsplug.wolframite import fields, translate


class FakeMatch:
    def __init__(self, matching_ids: set[int]) -> None:
        self.matching_ids = matching_ids

    def match(self, item: FakeModel) -> bool:
        return item.id in self.matching_ids


class FakeModel:
    def __init__(self, model_id: int, **values: Any) -> None:
        self.id = model_id
        self.path = f"/{model_id}.flac"
        self.values = values
        self.store_calls = 0
        self.write_calls = 0
        self.write_success = True

    def get(self, key: str, default: Any = None, **_kwargs) -> Any:
        return self.values.get(key, default)

    def __setitem__(self, key: str, value: Any) -> None:
        self.values[key] = value

    def set_parse(self, key: str, value: str) -> None:
        self.values[key] = value

    def _parse(self, _key: str, value: str) -> str:
        return value

    def store(self, **_kwargs) -> None:
        self.store_calls += 1

    def load(self) -> None:
        return None

    def try_write(self) -> bool:
        self.write_calls += 1
        return self.write_success


class FakeTransaction:
    def __enter__(self) -> FakeTransaction:
        return self

    def __exit__(self, exc_type, exc, traceback) -> None:
        return None

    def mutate(self, _statement: str) -> None:
        return None


class FakeLib:
    def transaction(self) -> FakeTransaction:
        return FakeTransaction()


class FakeSession:
    def __init__(self, write: bool = False) -> None:
        self.lib = FakeLib()
        self.config = {"write": FakeValue(write)}


class FakeValue:
    def __init__(self, value: bool) -> None:
        self.value = value

    def get(self, _type) -> bool:
        return self.value


class FakeTask:
    def __init__(
        self,
        items: list[FakeModel],
        album: FakeModel | None = None,
        choice_flag=None,
        applied_values: dict[str, Any] | None = None,
        is_album: bool | None = None,
    ) -> None:
        self._items = items
        self.album = album
        self.is_album = album is not None if is_album is None else is_album
        self.choice_flag = choice_flag
        self.apply = choice_flag is actions.Action.APPLY
        self.applied_values = applied_values or {}
        self.match = (
            SimpleNamespace(info={"artist": self.applied_values.get("albumartist")})
            if self.apply
            else None
        )

    def imported_items(self) -> list[FakeModel]:
        return self._items

    def apply_metadata(self) -> None:
        for item in self._items:
            item.values.update(self.applied_values)


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
        self._log = FakeLog()


class FakeLog:
    def __init__(self) -> None:
        self.warnings = []

    def warning(self, message: str, *args) -> None:
        self.warnings.append(message.format(*args))


def test_partial_album_field_translation_is_skipped(monkeypatch) -> None:
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

    assert item_a.get("albumartist") == "Old"
    assert item_b.get("albumartist") == "Old"
    assert album.get("albumartist") == "Old"

    assert item_a.store_calls == 0
    assert item_b.store_calls == 0
    assert album.store_calls == 0


def test_album_field_translation_requires_all_items(monkeypatch) -> None:
    item_a = FakeModel(1, artist="Oh Sees", albumartist="Old")
    item_b = FakeModel(2, artist="Oh Sees", albumartist="Old")
    album = FakeModel(10, albumartist="Old")
    task = FakeTask([item_a, item_b], album=album)
    session = FakeSession()
    rule = translate.TranslationRule(
        match=FakeMatch({1, 2}),
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


def test_validate_replacements_accepts_plugin_fields() -> None:
    translate._validate_replacements(
        {
            "collection": "Archive",
            "mood": ["heavy", "instrumental"],
            "stars": 4,
        }
    )


@pytest.mark.parametrize("field", ["id", "path", "album_id", "tracknumber"])
def test_validate_replacements_rejects_internal_fields(field: str) -> None:
    with pytest.raises(UserError, match="invalid field"):
        translate._validate_replacements({field: "value"})


def test_validate_replacements_rejects_list_for_scalar() -> None:
    with pytest.raises(UserError, match="requires a scalar"):
        translate._validate_replacements({"albumartist": ["A", "B"]})


@pytest.mark.parametrize(
    ("field", "value"),
    [
        ("year", "typo"),
        ("stars", "invalid"),
        ("comp", "maybe"),
        ("playlist_memberships", "[]"),
    ],
)
def test_validate_replacements_rejects_invalid_scalar_values(
    field: str,
    value: str,
) -> None:
    with pytest.raises(UserError, match="invalid value"):
        translate._validate_replacements({field: value})


def test_rules_parse_config_and_match_items() -> None:
    config.add({"sort_case_insensitive": False})
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


def test_rules_support_exact_query_prefix() -> None:
    config.add({"sort_case_insensitive": False})
    plugin = FakePlugin(
        [
            {
                "match": "artist:=Osees",
                "replacements": {"artist": "Osees"},
            }
        ]
    )
    rule = translate._rules(cast(BeetsPlugin, plugin))[0]

    assert rule.match.match(Item(artist="Osees"))
    assert not rule.match.match(Item(artist="The Osees"))


def test_asis_translation_writes_before_storing(monkeypatch) -> None:
    item = FakeModel(1, artist="Old")
    task = FakeTask([item], choice_flag=actions.Action.ASIS)
    session = FakeSession(write=True)
    rule = translate.TranslationRule(
        match=FakeMatch({1}),
        replacements={"artist": "New"},
    )
    monkeypatch.setattr(translate, "_rules", lambda _plugin: [rule])
    written = []
    monkeypatch.setattr(
        fields,
        "write_item_fields_batch",
        lambda changes: written.extend(changes),
    )

    translate.apply_field_translations(
        cast(BeetsPlugin, FakePlugin()),
        cast(ImportSession, session),
        cast(ImportTask, task),
    )

    assert written == [(item, {"artist"})]
    assert item.store_calls == 1


def test_asis_translation_keeps_earlier_file_and_database_updates_consistent(
    monkeypatch,
) -> None:
    item_a = FakeModel(1, artist="Old")
    item_b = FakeModel(2, artist="Old")
    task = FakeTask([item_a, item_b], choice_flag=actions.Action.ASIS)
    session = FakeSession(write=True)
    rule = translate.TranslationRule(
        match=FakeMatch({1, 2}),
        replacements={"artist": "New"},
    )
    monkeypatch.setattr(translate, "_rules", lambda _plugin: [rule])

    def write(changes) -> None:
        assert [model for model, _fields in changes] == [item_a, item_b]
        raise UserError("write failed")

    monkeypatch.setattr(fields, "write_item_fields_batch", write)

    with pytest.raises(UserError, match="write failed"):
        translate.apply_field_translations(
            cast(BeetsPlugin, FakePlugin()),
            cast(ImportSession, session),
            cast(ImportTask, task),
        )

    assert item_a.store_calls == 0
    assert item_b.store_calls == 0


def test_prepare_translation_changes_identity_before_duplicate_resolution(
    monkeypatch,
) -> None:
    item = FakeModel(1, albumartist="Source")
    task = FakeTask(
        [item],
        choice_flag=actions.Action.APPLY,
        applied_values={"albumartist": "Oh Sees"},
        is_album=True,
    )
    rule = translate.TranslationRule(
        match=FakeMatch({1}),
        replacements={"albumartist": "Osees"},
    )
    monkeypatch.setattr(translate, "_rules", lambda _plugin: [rule])

    translate.prepare_field_translations(
        cast(BeetsPlugin, FakePlugin()),
        cast(ImportTask, task),
    )

    assert item.get("albumartist") == "Osees"
    assert task.match is not None
    assert task.match.info["artist"] == "Osees"
    assert item.store_calls == 0


def test_prepare_records_falsey_authoritative_file_values(monkeypatch) -> None:
    item = FakeModel(
        1,
        collection="",
        lossy=False,
        mood=[],
        playlist_memberships="",
        stars=0,
    )
    task = FakeTask([item], choice_flag=actions.Action.ASIS)
    monkeypatch.setattr(translate, "_rules", lambda _plugin: [])

    translate.prepare_field_translations(
        cast(BeetsPlugin, FakePlugin()),
        cast(ImportTask, task),
    )

    recorded = getattr(task, "_wolframite_changed_fields")[item.path]
    assert recorded["collection"] == ""
    assert recorded["lossy"] is False
    assert recorded["mood"] == []
    assert recorded["playlist_memberships"] == ""
    assert recorded["stars"] == 0


def test_reapply_translation_restores_value_after_candidate_metadata(
    monkeypatch,
) -> None:
    item = FakeModel(1, artist="Oh Sees")
    task = FakeTask([item], choice_flag=actions.Action.APPLY)
    rule = translate.TranslationRule(
        match=FakeMatch({1}),
        replacements={"artist": "Osees"},
    )
    monkeypatch.setattr(translate, "_rules", lambda _plugin: [rule])

    translate.reapply_field_translations(
        cast(BeetsPlugin, FakePlugin()),
        cast(ImportTask, task),
    )

    assert item.get("artist") == "Osees"


def test_finish_translation_overrides_reimported_flexible_value() -> None:
    item = FakeModel(1, collection="Old")
    task = FakeTask([item], choice_flag=actions.Action.APPLY)
    setattr(
        task,
        "_wolframite_changed_fields",
        {item.path: {"collection": "New"}},
    )

    translate.finish_field_translations(
        cast(ImportSession, FakeSession()),
        cast(ImportTask, task),
    )

    assert item.get("collection") == "New"
    assert item.store_calls == 1


def test_finish_translation_replays_false_value() -> None:
    item = FakeModel(1, lossy=True)
    task = FakeTask([item], choice_flag=actions.Action.APPLY)
    setattr(
        task,
        "_wolframite_changed_fields",
        {item.path: {"lossy": False}},
    )

    translate.finish_field_translations(
        cast(ImportSession, FakeSession()),
        cast(ImportTask, task),
    )

    assert item.get("lossy") is False
    assert item.store_calls == 1


def test_finish_translation_repairs_album_row() -> None:
    item = FakeModel(1, albumartist="Osees")
    album = FakeModel(10, albumartist="Oh Sees")
    task = FakeTask([item], album=album, choice_flag=actions.Action.APPLY)
    setattr(
        task,
        "_wolframite_changed_fields",
        {item.path: {"albumartist": "Osees"}},
    )
    setattr(
        task,
        "_wolframite_album_fields",
        {"albumartist": "Osees"},
    )

    translate.finish_field_translations(
        cast(ImportSession, FakeSession()),
        cast(ImportTask, task),
    )

    assert album.get("albumartist") == "Osees"
    assert album.store_calls == 1

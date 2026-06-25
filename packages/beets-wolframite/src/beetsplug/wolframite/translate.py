"""Import-time field translation rules."""

from __future__ import annotations

import shlex
from collections.abc import Mapping
from dataclasses import dataclass
from typing import TYPE_CHECKING, Any, cast

import confuse
from beets.dbcore import AndQuery, query_from_strings
from beets.library import Album, Item
from beets.ui import UserError

if TYPE_CHECKING:
    from beets.importer import ImportSession, ImportTask
    from beets.plugins import BeetsPlugin


@dataclass(frozen=True)
class TranslationRule:
    match: Any
    replacements: dict[str, Any]


def apply_field_translations(
    plugin: BeetsPlugin,
    session: ImportSession,
    task: ImportTask,
) -> None:
    rules = _rules(plugin)
    if not rules:
        return

    items = task.imported_items()
    changed_items = set()
    album_changed = False

    for rule in rules:
        matching_items = [item for item in items if rule.match.match(item)]
        if not matching_items:
            continue

        for field, value in rule.replacements.items():
            if field in Item.all_keys():
                targets = _item_targets(field, matching_items, items)
                for item in targets:
                    _set_field(item, field, value)
                    changed_items.add(item)

            if task.is_album and hasattr(task, "album") and field in Album.all_keys():
                _set_field(task.album, field, value)
                album_changed = True

    with session.lib.transaction():
        for item in changed_items:
            item.store()
        if album_changed:
            task.album.store()


def _item_targets(
    field: str, matching_items: list[Item], all_items: list[Item]
) -> list[Item]:
    if field in Album.item_keys:
        return all_items
    return matching_items


def _set_field(model, field: str, value: Any) -> None:
    if isinstance(value, list):
        model[field] = [str(part) for part in value]
    else:
        model.set_parse(field, str(value))


def _rules(plugin: BeetsPlugin) -> list[TranslationRule]:
    template = confuse.Sequence(
        {
            "match": str,
            "replacements": confuse.MappingValues(
                confuse.OneOf([str, int, bool, confuse.Sequence(str)])
            ),
        }
    )

    rules = []
    for raw_rule in plugin.config["field_translations"].get(template):
        rule = cast(Mapping[str, Any], raw_rule)
        match = cast(str, rule["match"])
        replacements = dict(cast(Mapping[str, Any], rule["replacements"]))

        query = query_from_strings(
            AndQuery,
            Item,
            prefixes={},
            query_parts=shlex.split(match),
        )

        _validate_replacements(replacements)
        rules.append(TranslationRule(query, replacements))

    return rules


def _validate_replacements(replacements: dict[str, Any]) -> None:
    for field in replacements:
        if field not in Item.all_keys() and field not in Album.all_keys():
            raise UserError(f"invalid field in wolframite field translation: {field}")

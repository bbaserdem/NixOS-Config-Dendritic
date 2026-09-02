"""Import-time field translation rules."""

from __future__ import annotations

import math
from collections.abc import Mapping
from dataclasses import dataclass
from typing import TYPE_CHECKING, Any, cast

import confuse
from beets import util
from beets.dbcore import types as dbtypes
from beets.importer import actions
from beets.library import Album, Item, parse_query_string
from beets.ui import UserError

from . import fields

if TYPE_CHECKING:
    from beets.importer import ImportSession, ImportTask
    from beets.plugins import BeetsPlugin


@dataclass(frozen=True)
class TranslationRule:
    match: Any
    replacements: dict[str, Any]


TRANSLATABLE_ACTIONS = {
    actions.Action.APPLY,
    actions.Action.ASIS,
    actions.Action.RETAG,
}


def apply_field_translations(
    plugin: BeetsPlugin,
    session: ImportSession,
    task: ImportTask,
) -> None:
    _translated_items, changed_items, album_changed = _translate_task(plugin, task)
    if not changed_items and not album_changed:
        return

    _write_asis_changes(session, task, changed_items)

    with fields.atomic(session.lib):
        for item in changed_items:
            item.store()
        if album_changed:
            task.album.store()


def prepare_field_translations(plugin: BeetsPlugin, task: ImportTask) -> None:
    """Apply translations before duplicate resolution."""
    if getattr(task, "choice_flag", None) not in TRANSLATABLE_ACTIONS:
        return

    _remember_authoritative_fields(task)

    if task.apply:
        task.apply_metadata()

    translated_items, _changed_items, _album_changed = _translate_task(plugin, task)
    _sync_candidate_identity(task, translated_items)
    _remember_task_changes(task, translated_items)


def reapply_field_translations(plugin: BeetsPlugin, task: ImportTask) -> None:
    """Restore translations after beets reapplies candidate metadata."""
    translated_items, _changed_items, _album_changed = _translate_task(plugin, task)
    _remember_task_changes(task, translated_items)


def finish_field_translations(session: ImportSession, task: ImportTask) -> None:
    """Restore translated values after reimport preservation."""
    values_by_path = getattr(task, "_wolframite_changed_fields", {})
    translated_by_path = getattr(task, "_wolframite_translated_fields", {})
    items_to_store = []
    for item in task.imported_items():
        values = values_by_path.get(item.path, {})
        item.load()
        needs_store = False
        for field, value in values.items():
            if item.get(field, with_album=False) != value:
                item[field] = value
                needs_store = True

        if needs_store:
            items_to_store.append(item)

    album = getattr(task, "album", None)
    album_values = getattr(task, "_wolframite_album_fields", {})
    if album is not None and album_values:
        album.load()
        album_changed = False
        for field, value in album_values.items():
            if album.get(field) != value:
                album[field] = value
                album_changed = True
    with fields.atomic(session.lib):
        for item in items_to_store:
            item.store()
        if album is not None and album_values and album_changed:
            album.store(inherit=False)

    choice = getattr(task, "choice_flag", None)
    if session.config["write"].get(bool) and (
        choice in {actions.Action.APPLY, actions.Action.RETAG}
        or (choice == actions.Action.ASIS and any(translated_by_path.values()))
    ):
        setattr(task, "_wolframite_defer_media_write", True)


def write_deferred_import_fields(session: ImportSession, task: ImportTask) -> None:
    """Write imported metadata as a recoverable batch after file movement."""
    if not getattr(task, "_wolframite_defer_media_write", False):
        return

    choice = getattr(task, "choice_flag", None)
    translated_by_item = getattr(task, "_wolframite_translated_items", {})
    changes = []
    for item in task.imported_items():
        if choice == actions.Action.ASIS:
            selected_fields = translated_by_item.get(item, set())
        else:
            selected_fields = set(item.keys(with_album=False)) & set(
                item._media_tag_fields
            )
        if selected_fields:
            changes.append((item, selected_fields))

    fields.write_item_fields_batch(changes)
    with fields.atomic(session.lib):
        for item, _selected_fields in changes:
            item.store(fields={"mtime"})


def _translate_task(
    plugin: BeetsPlugin,
    task: ImportTask,
) -> tuple[dict, dict, bool]:
    rules = getattr(plugin, "_wolframite_field_translations", None)
    if rules is None:
        rules = _rules(plugin)
    if not rules:
        return {}, {}, False

    items = task.imported_items()
    translated_items = {}
    changed_items = {}
    album_changed = False
    album = getattr(task, "album", None)

    for rule in rules:
        matching_items = [item for item in items if rule.match.match(item)]
        if not matching_items:
            continue

        for field, value in rule.replacements.items():
            album_field = field in _album_translation_fields()
            if task.is_album and album_field and len(matching_items) != len(items):
                plugin._log.warning(
                    "Skipping album field {} because its rule matched only "
                    "{} of {} tracks",
                    field,
                    len(matching_items),
                    len(items),
                )
                continue

            targets = items if task.is_album and album_field else matching_items
            for item in targets:
                translated_items.setdefault(item, set()).add(field)
                if _set_field(item, field, value):
                    changed_items.setdefault(item, set()).add(field)

            if task.is_album and album_field and album is not None:
                album_changed = _set_field(album, field, value) or album_changed

    return translated_items, changed_items, album_changed


def _remember_task_changes(task: ImportTask, changed_items: dict) -> None:
    values_by_path = getattr(task, "_wolframite_changed_fields", {})
    translated_by_path = getattr(task, "_wolframite_translated_fields", {})
    translated_by_item = getattr(task, "_wolframite_translated_items", {})
    album_values = getattr(task, "_wolframite_album_fields", {})
    for item, changed_fields in changed_items.items():
        values = values_by_path.setdefault(item.path, {})
        values.update(
            {
                field: item.get(field, with_album=False)
                for field in changed_fields
            }
        )
        translated_by_path.setdefault(item.path, set()).update(changed_fields)
        translated_by_item.setdefault(item, set()).update(changed_fields)
        if task.is_album:
            album_values.update(
                {
                    field: item.get(field, with_album=False)
                    for field in changed_fields
                    if field in _album_translation_fields()
                }
            )
    setattr(task, "_wolframite_changed_fields", values_by_path)
    setattr(task, "_wolframite_translated_fields", translated_by_path)
    setattr(task, "_wolframite_translated_items", translated_by_item)
    setattr(task, "_wolframite_album_fields", album_values)


def _remember_authoritative_fields(task: ImportTask) -> None:
    values_by_path = getattr(task, "_wolframite_changed_fields", {})
    for item in task.imported_items():
        snapshot = getattr(item, "_wolframite_authoritative_fields", None)
        if snapshot is None:
            snapshot = {
                field: item.get(field, with_album=False)
                for field in fields.ITEM_TYPES
            }
            setattr(item, "_wolframite_authoritative_fields", snapshot)
        values = values_by_path.setdefault(item.path, {})
        for field, value in snapshot.items():
            values.setdefault(field, value)
    setattr(task, "_wolframite_changed_fields", values_by_path)


def _sync_candidate_identity(task: ImportTask, changed_items: dict) -> None:
    match = getattr(task, "match", None)
    if not task.apply or match is None:
        return

    for item, changed_fields in changed_items.items():
        for field in changed_fields:
            if task.is_album and field not in _album_translation_fields():
                continue
            candidate_field = "artist" if task.is_album and field == "albumartist" else field
            match.info[candidate_field] = item.get(field, with_album=False)


def validate_config(plugin: BeetsPlugin) -> None:
    """Parse translation rules before an import can add library rows."""
    setattr(plugin, "_wolframite_field_translations", _rules(plugin))


def _set_field(model, field: str, value: Any) -> bool:
    if isinstance(value, list):
        parsed = [str(part) for part in value]
    else:
        parsed = model._parse(field, str(value))

    if model.get(field) == parsed:
        return False

    model[field] = parsed
    return True


def _write_asis_changes(
    session,
    task,
    changed_items: dict[Item, set[str]],
) -> None:
    if (
        getattr(task, "choice_flag", None) != actions.Action.ASIS
        or not session.config["write"].get(bool)
    ):
        return

    fields.write_item_fields_batch(list(changed_items.items()))


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

        try:
            query, _sort = parse_query_string(match, Item)
        except Exception as exc:
            raise UserError(f"invalid wolframite field translation query: {exc}") from exc

        _validate_replacements(replacements)
        rules.append(TranslationRule(query, replacements))

    return rules


def _validate_replacements(replacements: dict[str, Any]) -> None:
    valid_fields = _item_translation_fields() | _album_translation_fields()

    for field, value in replacements.items():
        if field not in valid_fields:
            raise UserError(f"invalid field in wolframite field translation: {field}")

        field_types = []
        if field in _item_translation_fields():
            field_types.append(fields.ITEM_TYPES.get(field, Item._type(field)))
        if field in _album_translation_fields():
            field_types.append(fields.ALBUM_TYPES.get(field, Album._type(field)))

        if isinstance(value, list) and any(
            not isinstance(field_type.null, list) for field_type in field_types
        ):
            raise UserError(f"field translation requires a scalar value: {field}")
        if not isinstance(value, list):
            for field_type in field_types:
                _validate_scalar_replacement(field, value, field_type)


def _validate_scalar_replacement(field: str, value: Any, field_type) -> None:
    text = str(value)
    try:
        if isinstance(field_type, dbtypes.Boolean):
            if text.casefold() not in {
                "0",
                "1",
                "f",
                "false",
                "n",
                "no",
                "t",
                "true",
                "y",
                "yes",
            }:
                raise ValueError
            util.str2bool(text)
        elif isinstance(field_type, dbtypes.BaseInteger):
            number = float(text)
            if not math.isfinite(number):
                raise ValueError
        elif isinstance(field_type, dbtypes.BaseFloat) and not isinstance(
            field_type,
            dbtypes.DateType,
        ):
            number = float(text)
            if not math.isfinite(number):
                raise ValueError
        elif field == "playlist_memberships":
            fields.loads_playlist_memberships(value)
    except (AttributeError, TypeError, ValueError) as exc:
        raise UserError(f"invalid value for field translation {field}: {value}") from exc


def _item_translation_fields() -> set[str]:
    return set(Item._media_tag_fields) | set(fields.ITEM_TYPES)


def _album_translation_fields() -> set[str]:
    return (set(Album.item_keys) & _item_translation_fields()) | set(
        fields.ALBUM_TYPES
    )

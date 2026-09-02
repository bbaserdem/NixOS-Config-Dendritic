"""Custom database and media fields."""

from __future__ import annotations

import json
import uuid
from collections.abc import Iterator, Mapping
from contextlib import contextmanager
from fractions import Fraction
from functools import wraps
from typing import Any

import mediafile
from beets import config, library, plugins, ui
from beets.dbcore import types
from beets.library import Album
from beets.plugins import BeetsPlugin
from beets.ui import UserError
from beets.util import functemplate, syspath

from . import rating

_PENDING_FILE_FIELDS: dict[tuple[str, object], set[str]] = {}
_EXPLICIT_FILE_FIELDS: dict[tuple[str, object], set[str]] = {}
_FILE_AUTHORITY_PLUGIN: BeetsPlugin | None = None
PlaylistOrder = int | Fraction


@contextmanager
def atomic(lib: library.Library) -> Iterator[None]:
    """Rollback database changes when a grouped operation fails."""
    savepoint = f"wolframite_{uuid.uuid4().hex}"

    with lib.transaction() as transaction:
        transaction.mutate(f"SAVEPOINT {savepoint}")
        try:
            yield
        except BaseException:
            transaction.mutate(f"ROLLBACK TO SAVEPOINT {savepoint}")
            transaction.mutate(f"RELEASE SAVEPOINT {savepoint}")
            raise
        else:
            transaction.mutate(f"RELEASE SAVEPOINT {savepoint}")


def mp4_key(key: str) -> str:
    """Return iTunes-style MP4 freeform atom key."""
    return f"----:com.apple.iTunes:{key}"


def text_media_field(description: str, key: str) -> mediafile.MediaField:
    """Create a cross-format custom text tag."""
    return mediafile.MediaField(
        mediafile.MP3DescStorageStyle(description),
        mediafile.MP4StorageStyle(mp4_key(key)),
        mediafile.StorageStyle(key),
        mediafile.ASFStorageStyle(key),
    )


def bool_media_field(description: str, key: str) -> mediafile.MediaField:
    """Create a cross-format custom boolean tag stored as 1/0 text."""
    return mediafile.MediaField(
        mediafile.MP3DescStorageStyle(description),
        mediafile.MP4StorageStyle(mp4_key(key)),
        mediafile.StorageStyle(key),
        mediafile.ASFStorageStyle(key, as_type=bool),
        out_type=bool,
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


class StarsType(types.Integer):
    """Integer field constrained to the supported zero-to-five range."""

    def normalize(self, value: Any) -> int:
        return rating.clamp_stars(value)

    def parse(self, string: str) -> int:
        return self.normalize(string)

    def from_sql(self, sql_value) -> int:
        return self.normalize(sql_value)


STARS_TYPE = StarsType()

ITEM_TYPES = {
    **ALBUM_TYPES,
    "playlist_memberships": types.STRING,
    "stars": STARS_TYPE,
}


def register_media_fields(plugin: BeetsPlugin) -> None:
    """Register custom fields that should round-trip through media files."""
    for name, field in MEDIA_FIELDS.items():
        plugin.add_media_field(name, field)
        library.Item._media_tag_fields.add(name)

    owner = plugin.config["rating_owner"].as_str()
    plugin.add_media_field(
        "stars",
        rating.stars_media_field(owner),
    )
    library.Item._media_tag_fields.add("stars")


def install_item_store_compatibility() -> None:
    """Keep beets partial stores from treating our flexible fields as columns."""
    original_store = library.Item.store
    if getattr(original_store, "_wolframite_flexible_fields", False):
        return

    @wraps(original_store)
    def store(item, fields=None) -> None:
        pending = set(item._dirty) & set(item._media_tag_fields)
        if pending:
            _PENDING_FILE_FIELDS.setdefault(_pending_key(item), set()).update(pending)
        if fields is not None:
            fields = set(fields) - set(ITEM_TYPES)
        original_store(item, fields)

    setattr(store, "_wolframite_flexible_fields", True)
    setattr(library.Item, "store", store)


def install_strict_media_writes() -> None:
    """Prevent Beets callers from accepting a failed media write."""
    original_write = library.Item.try_write
    if getattr(original_write, "_wolframite_strict_write", False):
        return

    @wraps(original_write)
    def try_write(item, path=None, tags=None, id3v23=None) -> bool:
        if not original_write(item, path=path, tags=tags, id3v23=id3v23):
            raise UserError(f"failed to write tags for {item.filepath}")
        return True

    setattr(try_write, "_wolframite_strict_write", True)
    setattr(library.Item, "try_write", try_write)


def install_album_field_writes() -> None:
    """Batch album fields that are persisted in item media tags."""
    original_sync = library.Album.try_sync
    if getattr(original_sync, "_wolframite_album_write", False):
        return

    @wraps(original_sync)
    def try_sync(album, write, move, inherit=True) -> None:
        media_fields = set(album._dirty) & set(library.Item._media_tag_fields)
        if write and media_fields:
            changed_items = []
            for item in album.items():
                for field in media_fields:
                    item[field] = album.get(field)
                changed_items.append(item)

            write_item_fields_batch(
                [(item, media_fields) for item in changed_items]
            )
            with atomic(album.db):
                for item in changed_items:
                    item.store()
                album.store(inherit=False)

        original_sync(
            album,
            write=False if media_fields else write,
            move=move,
            inherit=inherit,
        )

    setattr(try_sync, "_wolframite_album_write", True)
    setattr(library.Album, "try_sync", try_sync)


def install_file_authority_listeners() -> None:
    """Protect unchanged custom fields during generic Beets writes."""
    global _FILE_AUTHORITY_PLUGIN
    if _FILE_AUTHORITY_PLUGIN is not None:
        return

    listener = BeetsPlugin("wolframite_file_authority")
    listener.register_listener("write", _protect_write_tags)
    listener.register_listener("after_write", _clear_pending_write_fields)
    _FILE_AUTHORITY_PLUGIN = listener


def install_file_authoritative_deletions() -> None:
    """Represent custom-field deletion as an on-file null value."""
    for model_class, field_types in (
        (library.Item, ITEM_TYPES),
        (library.Album, ALBUM_TYPES),
    ):
        original_delete = model_class.__delitem__
        if getattr(original_delete, "_wolframite_null_delete", False):
            continue

        @wraps(original_delete)
        def delete(model, key, _original=original_delete, _types=field_types) -> None:
            if key in _types:
                model[key] = _types[key].null
            else:
                _original(model, key)

        setattr(delete, "_wolframite_null_delete", True)
        setattr(model_class, "__delitem__", delete)


def install_reimport_fresh_fields() -> None:
    """Make file-backed fields replace stale database values on reimport."""
    from beets.importer import tasks

    for field in ITEM_TYPES:
        if field not in tasks.REIMPORT_FRESH_FIELDS_ITEM:
            tasks.REIMPORT_FRESH_FIELDS_ITEM.append(field)
    for field in ALBUM_TYPES:
        if field not in tasks.REIMPORT_FRESH_FIELDS_ALBUM:
            tasks.REIMPORT_FRESH_FIELDS_ALBUM.append(field)


def write_item_fields(item: library.Item, selected_fields: set[str]) -> None:
    """Write only selected fields and persist the resulting file mtime."""
    write_item_values(
        item,
        {
        field: item.get(field, with_album=False)
        for field in selected_fields
        },
    )


def write_item_values(item: library.Item, tags: Mapping[str, Any]) -> None:
    """Write explicit values without serializing unrelated database fields."""
    path = item.path
    tags = dict(tags)
    pending_key = _pending_key(item)
    explicit = _EXPLICIT_FILE_FIELDS.setdefault(pending_key, set())
    explicit.update(tags)

    try:
        plugins.send("write", item=item, path=path, tags=tags)
        media = mediafile.MediaFile(
            syspath(path),
            id3v23=config["id3v23"].get(bool),
        )
        media.update(tags)
        media.save()
    except (OSError, TypeError, mediafile.UnreadableFileError, ValueError) as exc:
        raise UserError(f"could not write tags for item {item.id}: {exc}") from exc
    finally:
        explicit.difference_update(tags)
        if not explicit:
            _EXPLICIT_FILE_FIELDS.pop(pending_key, None)

    item.mtime = item.current_mtime()
    plugins.send("after_write", item=item, path=path)


def read_item_fields(item: library.Item, selected_fields: set[str]) -> dict[str, Any]:
    """Read authoritative fields directly from a media file."""
    return _read_media_fields(item.path, selected_fields, item.id)


def _read_media_fields(path, selected_fields: set[str], item_id=None) -> dict[str, Any]:
    try:
        media = mediafile.MediaFile(
            syspath(path),
            id3v23=config["id3v23"].get(bool),
        )
        return {field: getattr(media, field) for field in selected_fields}
    except (OSError, TypeError, mediafile.UnreadableFileError, ValueError) as exc:
        raise UserError(f"could not read tags for item {item_id}: {exc}") from exc


def read_item_field(item: library.Item, field: str):
    return read_item_fields(item, {field})[field]


def write_item_fields_batch(
    changes: list[tuple[library.Item, set[str]]],
) -> None:
    """Write a field-limited batch and roll back earlier files on failure."""
    snapshots = [
        (item, read_item_fields(item, selected_fields))
        for item, selected_fields in changes
    ]
    written = []

    try:
        for item, selected_fields in changes:
            written.append(item)
            write_item_fields(item, selected_fields)
    except Exception as exc:
        rollback_errors = []
        snapshots_by_item = {item: values for item, values in snapshots}
        for item in reversed(written):
            try:
                write_item_values(item, snapshots_by_item[item])
            except Exception as rollback_exc:
                rollback_errors.append(str(rollback_exc))

        if rollback_errors:
            detail = "; ".join(rollback_errors)
            raise UserError(f"{exc}; rollback also failed: {detail}") from exc
        raise


def _pending_key(item: library.Item) -> tuple[str, object]:
    return ("id", item.id) if item.id is not None else ("path", item.path)


def _protect_write_tags(item, path, tags) -> None:
    key = _pending_key(item)
    candidate_fields = set(tags) & set(item._media_tag_fields)
    intended = (
        (set(item._dirty) & set(item._media_tag_fields))
        | _PENDING_FILE_FIELDS.get(key, set())
        | _EXPLICIT_FILE_FIELDS.get(key, set())
    )
    protected = candidate_fields - intended
    if protected:
        values = _read_media_fields(item.path, protected, item.id)
        tags.update(values)
        for field, value in values.items():
            if item.get(field, with_album=False) != value:
                item[field] = value


def _clear_pending_write_fields(item, path) -> None:
    _PENDING_FILE_FIELDS.pop(_pending_key(item), None)


def loads_playlist_memberships(value: Any) -> dict[str, PlaylistOrder]:
    """Parse playlist membership JSON from a beets field."""
    if not value:
        return {}

    if isinstance(value, dict):
        raw = value
    else:
        raw = json.loads(str(value))

    return {
        str(name): _parse_playlist_order(order)
        for name, order in raw.items()
        if str(name) and order is not None
    }


def dumps_playlist_memberships(value: Mapping[str, PlaylistOrder]) -> str:
    """Serialize playlist memberships in stable form."""
    return json.dumps(
        {str(name): _dump_playlist_order(order) for name, order in value.items()},
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    )


def _parse_playlist_order(value: Any) -> PlaylistOrder:
    order = Fraction(str(value))
    return order.numerator if order.denominator == 1 else order


def _dump_playlist_order(value: PlaylistOrder) -> int | str:
    order = Fraction(value)
    return order.numerator if order.denominator == 1 else str(order)


def propagated_album_fields() -> set[str]:
    """Custom album fields that also exist on items."""
    return set(ALBUM_TYPES) & set(ITEM_TYPES)


def sync_album_fields_to_items(
    album: Album,
    changed_fields: set[str],
    write: bool = False,
    store: bool = True,
) -> list:
    fields = changed_fields & propagated_album_fields()
    if not fields:
        return []

    changed_items = []

    for item in album.items():
        dirty = set()

        for field in fields:
            value = album.get(field)
            if item.get(field, with_album=False) != value:
                item[field] = value
                dirty.add(field)

        if dirty:
            if write:
                write_item_fields(item, dirty)
            if store:
                item.store()
            changed_items.append(item)

    return changed_items


def sync_item_fields_to_album(album: Album) -> set[str]:
    """Rebuild album fields that have one unanimous non-empty item value."""
    items = list(album.items())
    if not items:
        return set()

    changed = set()
    for field in propagated_album_fields():
        values = [item.get(field, with_album=False) for item in items]
        value = values[0] if all(current == values[0] for current in values) else None
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


def sync_read_item_fields_to_album(album: Album, item: library.Item) -> set[str]:
    """Refresh album copies before update computes item destinations."""
    changed = set()
    for field in propagated_album_fields():
        value = item.get(field, with_album=False)
        if album.get(field) != value:
            album[field] = value
            changed.add(field)

    if changed:
        album.store(inherit=False)
    return changed


def commands():
    cmd = ui.Subcommand(
        "propagate",
        help="modify album fields and propagate matching item fields",
    )
    cmd.parser.add_option(
        "-y",
        "--yes",
        action="store_true",
        help="skip confirmation",
    )
    cmd.parser.add_option(
        "-w",
        "--write",
        action="store_true",
        dest="write",
        default=None,
        help="write propagated fields to media files",
    )
    cmd.parser.add_option(
        "-W",
        "--nowrite",
        action="store_false",
        dest="write",
        help="change only the disposable database",
    )
    cmd.func = wmod_func
    return [cmd]


def parse_mod_args(args: list[str]) -> tuple[list[str], dict[str, str]]:
    mods = {}
    query = []

    for arg in args:
        if "=" in arg and ":" not in arg.split("=", 1)[0]:
            key, value = arg.split("=", 1)
            if key not in ALBUM_TYPES:
                raise UserError(f"not a user album field: {key}")
            mods[key] = value
        else:
            query.append(arg)

    if not mods:
        raise UserError("no album field assignments specified")

    return query, mods


def wmod_func(lib, opts, args):
    query, mods = parse_mod_args(args)
    albums = list(lib.albums(query))

    if not albums:
        raise UserError("No matching albums found.")

    templates = {key: functemplate.template(value) for key, value in mods.items()}

    changed_albums = []

    for album in albums:
        parsed = {
            key: album._parse(key, album.evaluate_template(templates[key]))
            for key in mods
        }

        album_changed = any(album.get(key) != value for key, value in parsed.items())
        item_changed = any(
            item.get(key, with_album=False) != value
            for item in album.items()
            for key, value in parsed.items()
        )

        if album_changed or item_changed:
            changed_albums.append((album, parsed))

    if not changed_albums:
        ui.print_("No changes to make.")
        return

    ui.print_(f"Modifying {len(changed_albums)} albums.")

    if not opts.yes:
        if not ui.input_yn("Really modify albums and propagate fields?", False):
            return

    write = ui.should_write(opts.write)
    if write:
        changed_items = []
        writes = []
        for album, parsed in changed_albums:
            for key, value in parsed.items():
                album[key] = value
            items = sync_album_fields_to_items(
                album,
                set(parsed),
                store=False,
            )
            changed_items.extend(items)
            writes.extend((item, set(parsed)) for item in items)

        write_item_fields_batch(writes)
        with atomic(lib):
            for item in changed_items:
                item.store()
            for album, _parsed in changed_albums:
                album.store(inherit=False)
        return

    with atomic(lib):
        for album, parsed in changed_albums:
            for key, value in parsed.items():
                album[key] = value
            album.store(inherit=False)
            sync_album_fields_to_items(album, set(parsed))

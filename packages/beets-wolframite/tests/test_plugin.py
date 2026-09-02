from __future__ import annotations

from collections import defaultdict

from beets import plugins
from beets.library import Item, Library

from beetsplug.wolframite import WolframitePlugin, fields


def test_album_database_change_uses_native_item_inheritance(
    tmp_path,
    monkeypatch,
) -> None:
    monkeypatch.setattr(plugins.BeetsPlugin, "_raw_listeners", defaultdict(list))
    monkeypatch.setattr(plugins.BeetsPlugin, "listeners", defaultdict(list))
    monkeypatch.setattr(fields, "register_media_fields", lambda _plugin: None)

    WolframitePlugin()
    library = Library(
        path=tmp_path / "library.db",
        directory=str(tmp_path / "music"),
    )
    item = Item(
        path=tmp_path / "track.flac",
        album="Album",
        albumartist="Artist",
        artist="Artist",
        title="Track",
    )

    album = library.add_album([item])
    album["collection"] = "Archive"
    album.store()

    stored_item = library.items().get()
    assert stored_item is not None
    assert stored_item.get("collection", with_album=False) == "Archive"


def test_partial_store_accepts_wolframite_flexible_fields(tmp_path) -> None:
    fields.install_item_store_compatibility()
    library = Library(
        path=tmp_path / "library.db",
        directory=str(tmp_path / "music"),
    )
    item = Item(path=tmp_path / "track.flac", title="Track")
    library.add(item)

    item["collection"] = "Archive"
    item.store(fields={"collection"})

    assert item.id is not None
    stored_item = library.get_item(item.id)
    assert stored_item is not None
    assert stored_item.get("collection", with_album=False) == "Archive"


def test_album_fields_are_rebuilt_from_unanimous_items(tmp_path) -> None:
    library = Library(
        path=tmp_path / "library.db",
        directory=str(tmp_path / "music"),
    )
    items = [
        Item(path=tmp_path / f"track-{index}.flac", title=f"Track {index}")
        for index in range(2)
    ]
    for item in items:
        item["collection"] = "Archive"

    album = library.add_album(items)
    changed = fields.sync_item_fields_to_album(album)

    assert changed == {"collection"}
    assert album.id is not None
    stored_album = library.get_album(album.id)
    assert stored_album is not None
    assert stored_album.get("collection") == "Archive"


def test_conflicting_item_fields_clear_album_copy(tmp_path) -> None:
    library = Library(
        path=tmp_path / "library.db",
        directory=str(tmp_path / "music"),
    )
    item_a = Item(path=tmp_path / "a.flac", title="A", collection="A")
    item_b = Item(path=tmp_path / "b.flac", title="B", collection="B")
    album = library.add_album([item_a, item_b])
    album["collection"] = "Stale"
    album.store(inherit=False)

    changed = fields.sync_item_fields_to_album(album)

    assert changed == {"collection"}
    assert album.get("collection") == ""
    assert item_a.get("collection", with_album=False) == "A"
    assert item_b.get("collection", with_album=False) == "B"


def test_update_refreshes_album_copy_from_read_item(tmp_path) -> None:
    library = Library(
        path=tmp_path / "library.db",
        directory=str(tmp_path / "music"),
    )
    item = Item(path=tmp_path / "track.flac", title="Track", collection="Old")
    album = library.add_album([item])
    album["collection"] = "Old"
    album.store(inherit=False)
    item["collection"] = "New"

    changed = fields.sync_read_item_fields_to_album(album, item)

    assert changed == {"collection"}
    assert album.get("collection") == "New"

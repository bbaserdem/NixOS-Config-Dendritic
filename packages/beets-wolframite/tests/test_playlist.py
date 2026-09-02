from __future__ import annotations

from pathlib import Path
from fractions import Fraction
from types import SimpleNamespace
from typing import cast

import pytest
from beets.library import Library
from beets.ui import UserError

from beetsplug.wolframite import fields, playlist


@pytest.fixture(autouse=True)
def fake_media_io(monkeypatch) -> None:
    monkeypatch.setattr(
        fields,
        "read_item_field",
        lambda item, _field: item.get("playlist_memberships"),
    )

    def write_batch(changes) -> None:
        for item, _selected_fields in changes:
            item.write_calls += 1
            if not item.write_success:
                raise UserError(f"could not write tags for item {item.id}")

    monkeypatch.setattr(fields, "write_item_fields_batch", write_batch)


class FakeItem:
    def __init__(
        self,
        item_id: int,
        path: Path,
        memberships: dict[str, int] | None = None,
        write_success: bool = True,
        **values,
    ) -> None:
        self.id = item_id
        self.path = path
        self.values = {
            "playlist_memberships": fields.dumps_playlist_memberships(
                memberships or {}
            ),
            "albumartist": values.get("albumartist", ""),
            "album": values.get("album", ""),
            "disc": values.get("disc", 0),
            "track": values.get("track", 0),
            "title": values.get("title", ""),
        }
        self.store_calls = 0
        self.write_calls = 0
        self.write_success = write_success

    def evaluate_template(self, template, _for_path: bool = False) -> str:
        return str(template)

    def get(self, key: str, default=None):
        return self.values.get(key, default)

    def __setitem__(self, key: str, value) -> None:
        self.values[key] = value

    def store(self) -> None:
        self.store_calls += 1

    def try_write(self) -> bool:
        self.write_calls += 1
        return self.write_success


class FakeTransaction:
    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, traceback) -> None:
        return None

    def mutate(self, _statement: str) -> None:
        return None


class FakeLib:
    def __init__(self, directory: Path, items: list[FakeItem]) -> None:
        self.directory = directory
        self.replacements = []
        self._items = items

    def items(self):
        return list(self._items)

    def transaction(self):
        return FakeTransaction()


def test_normalize_playlist_name() -> None:
    assert playlist._normalize_playlist_name("Roadtrip") == "Roadtrip"
    assert playlist._normalize_playlist_name("Roadtrip.m3u") == "Roadtrip"
    assert playlist._normalize_playlist_name("Roadtrip.m3u8") == "Roadtrip"


@pytest.mark.parametrize(
    "name",
    ["", ".", "..", "Nested/List", "CON", "Mix:2026", "A?B", "Trailing."],
)
def test_normalize_playlist_name_rejects_invalid_names(name: str) -> None:
    with pytest.raises(UserError):
        playlist._normalize_playlist_name(name)


def test_read_m3u_missing_file(tmp_path: Path) -> None:
    missing = tmp_path / "Missing.m3u"

    with pytest.raises(UserError, match="playlist file does not exist"):
        playlist._read_m3u(missing, tmp_path)


def test_read_m3u_rejects_non_playlist_suffix(tmp_path: Path) -> None:
    path = tmp_path / "Playlist.txt"
    path.write_text("", encoding="utf-8")

    with pytest.raises(UserError, match="must end with"):
        playlist._read_m3u(path, tmp_path)


def test_read_m3u_resolves_relative_paths(tmp_path: Path) -> None:
    path = tmp_path / "Playlist.m3u"
    path.write_text(
        "\n".join(
            [
                "#EXTM3U",
                "Core/Artist/Album/01 Track.flac",
                "",
            ]
        ),
        encoding="utf-8",
    )

    assert playlist._read_m3u(path, tmp_path) == [
        tmp_path / "Core/Artist/Album/01 Track.flac",
    ]


def test_generate_playlist_uses_membership_order(tmp_path: Path, monkeypatch) -> None:
    music_dir = tmp_path / "Music"
    playlist_dir = tmp_path / "Playlists"

    item_a = FakeItem(
        1,
        music_dir / "Core/A.flac",
        {"Roadtrip": 200},
        title="A",
        track=2,
    )
    item_b = FakeItem(
        2,
        music_dir / "Core/B.flac",
        {"Roadtrip": 100},
        title="B",
        track=1,
    )
    lib = FakeLib(music_dir, [item_a, item_b])

    monkeypatch.setattr(playlist, "_playlist_dir", lambda _lib: playlist_dir)
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)
    monkeypatch.setattr(playlist, "_forward_slash", lambda: True)

    generated = playlist.generate_playlist(cast(Library, lib), "Roadtrip")

    assert generated == playlist_dir / "Roadtrip.m3u"
    assert generated.read_text(encoding="utf-8").splitlines() == [
        playlist.GENERATED_MARKER,
        "Core/B.flac",
        "Core/A.flac",
    ]


def test_generate_playlist_errors_for_empty_playlist(tmp_path: Path) -> None:
    lib = FakeLib(tmp_path, [])

    with pytest.raises(UserError, match="playlist has no members"):
        playlist.generate_playlist(cast(Library, lib), "Roadtrip")


def test_save_playlist_overwrites_named_membership(tmp_path: Path, monkeypatch) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()

    item_a_path = music_dir / "A.flac"
    item_b_path = music_dir / "B.flac"
    item_c_path = music_dir / "C.flac"

    item_a_path.write_text("", encoding="utf-8")
    item_b_path.write_text("", encoding="utf-8")
    item_c_path.write_text("", encoding="utf-8")

    item_a = FakeItem(1, item_a_path, {"Roadtrip": 999, "Other": 100})
    item_b = FakeItem(2, item_b_path, {})
    item_c = FakeItem(3, item_c_path, {"Roadtrip": 123})
    lib = FakeLib(music_dir, [item_a, item_b, item_c])

    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("B.flac\nA.flac\n", encoding="utf-8")

    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    changed = playlist.save_playlist(cast(Library, lib), playlist_path, write=True)

    assert changed == 2
    assert fields.loads_playlist_memberships(item_a.get("playlist_memberships")) == {
        "Other": 100,
        "Roadtrip": 999,
    }
    assert fields.loads_playlist_memberships(item_b.get("playlist_memberships")) == {
        "Roadtrip": 899,
    }
    assert fields.loads_playlist_memberships(item_c.get("playlist_memberships")) == {}

    assert item_a.store_calls == 0
    assert item_b.store_calls == 1
    assert item_c.store_calls == 1
    assert item_a.write_calls == 0
    assert item_b.write_calls == 1
    assert item_c.write_calls == 1


def test_save_playlist_errors_for_missing_item_path(
    tmp_path: Path, monkeypatch
) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()

    item_path = music_dir / "A.flac"
    item_path.write_text("", encoding="utf-8")

    lib = FakeLib(music_dir, [FakeItem(1, item_path)])
    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("Missing.flac\n", encoding="utf-8")

    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    with pytest.raises(UserError, match="paths not in beets library"):
        playlist.save_playlist(cast(Library, lib), playlist_path, write=False)


def test_save_playlist_requires_explicit_empty_clear(
    tmp_path: Path,
    monkeypatch,
) -> None:
    item = FakeItem(1, tmp_path / "A.flac", {"Roadtrip": 100})
    lib = FakeLib(tmp_path, [item])
    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("# empty\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: tmp_path)

    with pytest.raises(UserError, match="--allow-empty"):
        playlist.save_playlist(cast(Library, lib), playlist_path, write=False)

    changed = playlist.save_playlist(
        cast(Library, lib),
        playlist_path,
        write=False,
        allow_empty=True,
    )
    assert changed == 1
    assert fields.loads_playlist_memberships(item.get("playlist_memberships")) == {}


def test_save_playlist_write_failure_is_retryable(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()
    item_path = music_dir / "A.flac"
    item_path.write_text("", encoding="utf-8")
    item = FakeItem(1, item_path, write_success=False)
    lib = FakeLib(music_dir, [item])
    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("A.flac\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    with pytest.raises(UserError, match="could not write tags"):
        playlist.save_playlist(cast(Library, lib), playlist_path, write=True)

    assert item.store_calls == 0
    assert item.write_calls == 1


def test_save_playlist_keeps_successful_items_consistent_on_later_failure(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()
    item_a = FakeItem(1, music_dir / "A.flac")
    item_b = FakeItem(2, music_dir / "B.flac", write_success=False)
    for item in (item_a, item_b):
        item.path.write_text("", encoding="utf-8")
    lib = FakeLib(music_dir, [item_a, item_b])
    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("A.flac\nB.flac\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    with pytest.raises(UserError, match="could not write tags"):
        playlist.save_playlist(cast(Library, lib), playlist_path, write=True)

    assert item_a.store_calls == 0
    assert item_b.store_calls == 0


def test_save_playlist_replaces_canonical_name_aliases(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()
    item = FakeItem(1, music_dir / "A.flac", {"Roadtrip.m3u": 900})
    item.path.write_text("", encoding="utf-8")
    lib = FakeLib(music_dir, [item])
    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("A.flac\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    playlist.save_playlist(cast(Library, lib), playlist_path, write=False)

    assert fields.loads_playlist_memberships(item.get("playlist_memberships")) == {
        "Roadtrip": 900
    }


def test_save_playlist_preserves_ranks_when_order_is_unchanged(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()
    item_a = FakeItem(1, music_dir / "A.flac", {"Roadtrip": 100})
    item_c = FakeItem(3, music_dir / "C.flac", {"Roadtrip": 300})
    for item in (item_a, item_c):
        item.path.write_text("", encoding="utf-8")
    lib = FakeLib(music_dir, [item_a, item_c])
    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("A.flac\nC.flac\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    changed = playlist.save_playlist(
        cast(Library, lib),
        playlist_path,
        write=False,
    )

    assert changed == 0
    assert fields.loads_playlist_memberships(item_a.get("playlist_memberships")) == {
        "Roadtrip": 100
    }
    assert fields.loads_playlist_memberships(item_c.get("playlist_memberships")) == {
        "Roadtrip": 300
    }


def test_save_playlist_inserts_into_existing_rank_gap(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()
    item_a = FakeItem(1, music_dir / "A.flac", {"Roadtrip": 100})
    item_b = FakeItem(2, music_dir / "B.flac")
    item_c = FakeItem(3, music_dir / "C.flac", {"Roadtrip": 300})
    for item in (item_a, item_b, item_c):
        item.path.write_text("", encoding="utf-8")
    lib = FakeLib(music_dir, [item_a, item_b, item_c])
    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("A.flac\nB.flac\nC.flac\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    playlist.save_playlist(cast(Library, lib), playlist_path, write=False)

    assert fields.loads_playlist_memberships(item_a.get("playlist_memberships")) == {
        "Roadtrip": 100
    }
    assert fields.loads_playlist_memberships(item_b.get("playlist_memberships")) == {
        "Roadtrip": 200
    }
    assert fields.loads_playlist_memberships(item_c.get("playlist_memberships")) == {
        "Roadtrip": 300
    }


def test_save_playlist_uses_fraction_when_integer_gap_is_exhausted(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()
    item_a = FakeItem(1, music_dir / "A.flac", {"Roadtrip": 10})
    item_b = FakeItem(2, music_dir / "B.flac")
    item_c = FakeItem(3, music_dir / "C.flac", {"Roadtrip": 11})
    for item in (item_a, item_b, item_c):
        item.path.write_text("", encoding="utf-8")
    lib = FakeLib(music_dir, [item_a, item_b, item_c])
    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("A.flac\nB.flac\nC.flac\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    playlist.save_playlist(cast(Library, lib), playlist_path, write=False)

    memberships_a = fields.loads_playlist_memberships(
        item_a.get("playlist_memberships")
    )
    memberships_b = fields.loads_playlist_memberships(
        item_b.get("playlist_memberships")
    )
    memberships_c = fields.loads_playlist_memberships(
        item_c.get("playlist_memberships")
    )
    assert memberships_a["Roadtrip"] == 10
    assert memberships_b["Roadtrip"] == Fraction(21, 2)
    assert memberships_c["Roadtrip"] == 11


def test_save_playlist_merges_other_playlists_from_file(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()
    item = FakeItem(1, music_dir / "A.flac", {"Old": 100})
    item.path.write_text("", encoding="utf-8")
    lib = FakeLib(music_dir, [item])
    playlist_path = tmp_path / "Local.m3u"
    playlist_path.write_text("A.flac\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)
    monkeypatch.setattr(
        fields,
        "read_item_field",
        lambda _item, _field: fields.dumps_playlist_memberships(
            {"Old": 100, "Remote": 100}
        ),
    )

    playlist.save_playlist(cast(Library, lib), playlist_path, write=True)

    assert fields.loads_playlist_memberships(item.get("playlist_memberships")) == {
        "Local": 100,
        "Old": 100,
        "Remote": 100,
    }


def test_nowrite_save_can_later_be_promoted_to_files(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()
    item = FakeItem(1, music_dir / "A.flac")
    item.path.write_text("", encoding="utf-8")
    lib = FakeLib(music_dir, [item])
    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("A.flac\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    playlist.save_playlist(cast(Library, lib), playlist_path, write=False)
    assert item.write_calls == 0
    monkeypatch.setattr(fields, "read_item_field", lambda _item, _field: "")

    playlist.save_playlist(cast(Library, lib), playlist_path, write=True)

    assert item.write_calls == 1


def test_generate_refuses_to_overwrite_unowned_playlist(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    playlist_dir = tmp_path / "Playlists"
    playlist_dir.mkdir()
    output = playlist_dir / "Roadtrip.m3u"
    output.write_text("manual\n", encoding="utf-8")
    item = FakeItem(1, music_dir / "A.flac", {"Roadtrip": 100})
    lib = FakeLib(music_dir, [item])
    monkeypatch.setattr(playlist, "_playlist_dir", lambda _lib: playlist_dir)
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    with pytest.raises(UserError, match="unowned playlist"):
        playlist.generate_playlist(cast(Library, lib), "Roadtrip")

    assert output.read_text(encoding="utf-8") == "manual\n"


def test_generate_reads_memberships_from_file_not_database(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    playlist_dir = tmp_path / "Playlists"
    item = FakeItem(1, music_dir / "A.flac")
    lib = FakeLib(music_dir, [item])
    monkeypatch.setattr(playlist, "_playlist_dir", lambda _lib: playlist_dir)
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)
    monkeypatch.setattr(
        fields,
        "read_item_field",
        lambda _item, _field: fields.dumps_playlist_memberships(
            {"Roadtrip": 100}
        ),
    )

    output = playlist.generate_playlist(cast(Library, lib), "Roadtrip")

    assert output.exists()
    assert "A.flac" in output.read_text(encoding="utf-8")


def test_playlist_identity_is_unicode_and_case_normalized() -> None:
    assert playlist._name_key("MI\u0307X") == playlist._name_key("MİX")
    assert playlist._name_key("Mix") == playlist._name_key("mix")
    assert playlist._normalize_playlist_name("Roadtrip.m3u.m3u") == "Roadtrip"


def test_save_playlist_rejects_duplicate_items(tmp_path: Path, monkeypatch) -> None:
    music_dir = tmp_path / "Music"
    music_dir.mkdir()
    item = FakeItem(1, music_dir / "A.flac")
    item.path.write_text("", encoding="utf-8")
    lib = FakeLib(music_dir, [item])
    playlist_path = tmp_path / "Roadtrip.m3u"
    playlist_path.write_text("A.flac\nA.flac\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    with pytest.raises(UserError, match="more than once"):
        playlist.save_playlist(cast(Library, lib), playlist_path, write=False)


def test_generate_all_removes_only_stale_owned_playlists(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    playlist_dir = tmp_path / "Playlists"
    playlist_dir.mkdir()
    item = FakeItem(1, music_dir / "A.flac", {"Current": 100})
    lib = FakeLib(music_dir, [item])
    stale = playlist_dir / "Stale.m3u"
    stale.write_text(f"{playlist.GENERATED_MARKER}\nold\n", encoding="utf-8")
    foreign = playlist_dir / "Foreign.m3u"
    foreign.write_text("manual\n", encoding="utf-8")
    monkeypatch.setattr(playlist, "_playlist_dir", lambda _lib: playlist_dir)
    monkeypatch.setattr(playlist, "_relative_to", lambda _lib, _path: music_dir)

    playlist.generate_all_playlists(cast(Library, lib))

    assert not stale.exists()
    assert foreign.exists()


class FakeConfigValue:
    def __init__(self, value) -> None:
        self.value = value

    def get(self, _template=None):
        return self.value

    def as_filename(self) -> str:
        return str(self.value)


class FakeSmartPlaylist:
    def __init__(self, directory: Path, items_by_query: dict[str, list]) -> None:
        self.config = {
            "output": FakeConfigValue("m3u"),
            "playlist_dir": FakeConfigValue(directory),
            "pretend": FakeConfigValue(False),
        }
        self.items_by_query = items_by_query

    def get_playlist_items(self, _lib, item_query, _album_query):
        return iter(self.items_by_query[item_query])


def test_reconcile_smartplaylists_does_not_let_empty_definition_win(
    tmp_path: Path,
) -> None:
    output = tmp_path / "Shared.m3u"
    output.write_text("track.flac\n", encoding="utf-8")
    item = SimpleNamespace(evaluate_template=lambda _name, _for_path: "Shared.m3u")
    plugin = FakeSmartPlaylist(tmp_path, {"full": [item], "empty": []})
    definitions = {
        ("Shared.m3u", "full", None),
        ("Shared.m3u", "empty", None),
    }

    playlist.reconcile_smartplaylists(
        plugin,
        cast(Library, FakeLib(tmp_path, [])),
        definitions,
        full_update=True,
    )

    assert output.read_text(encoding="utf-8") == (
        f"{playlist.SMARTPLAYLIST_MARKER}\ntrack.flac\n"
    )


def test_reconcile_smartplaylists_removes_manifest_owned_orphans(
    tmp_path: Path,
) -> None:
    stale = tmp_path / "Old-Rock.m3u"
    stale.write_text(
        f"{playlist.SMARTPLAYLIST_MARKER}\nold.flac\n",
        encoding="utf-8",
    )
    manifest = tmp_path / playlist.SMARTPLAYLIST_MANIFEST
    manifest.write_text('["Old-Rock.m3u"]\n', encoding="utf-8")
    plugin = FakeSmartPlaylist(tmp_path, {})

    playlist.reconcile_smartplaylists(
        plugin,
        cast(Library, FakeLib(tmp_path, [])),
        set(),
        full_update=True,
    )

    assert not stale.exists()


def test_smartplaylist_manifest_does_not_authorize_unmarked_file(
    tmp_path: Path,
) -> None:
    output = tmp_path / "Shared.m3u"
    output.write_text("manual\n", encoding="utf-8")
    manifest = tmp_path / playlist.SMARTPLAYLIST_MANIFEST
    manifest.write_text('{"Shared.m3u":["Shared.m3u"]}\n', encoding="utf-8")
    item = SimpleNamespace(evaluate_template=lambda _name, _for_path: "Shared.m3u")
    plugin = FakeSmartPlaylist(tmp_path, {"full": [item]})

    with pytest.raises(UserError, match="unowned smartplaylist"):
        playlist.validate_smartplaylist_outputs(
            plugin,
            cast(Library, FakeLib(tmp_path, [])),
            {("Shared.m3u", "full", None)},
        )

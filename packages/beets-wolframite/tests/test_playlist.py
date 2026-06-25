from __future__ import annotations

from pathlib import Path
from typing import cast

import pytest
from beets.library import Library
from beets.ui import UserError

from beetsplug.wolframite import fields, playlist


class FakeItem:
    def __init__(
        self,
        item_id: int,
        path: Path,
        memberships: dict[str, int] | None = None,
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

    def get(self, key: str, default=None):
        return self.values.get(key, default)

    def __setitem__(self, key: str, value) -> None:
        self.values[key] = value

    def store(self) -> None:
        self.store_calls += 1

    def try_write(self) -> None:
        self.write_calls += 1


class FakeTransaction:
    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, traceback) -> None:
        return None


class FakeLib:
    def __init__(self, directory: Path, items: list[FakeItem]) -> None:
        self.directory = directory
        self._items = items

    def items(self):
        return list(self._items)

    def transaction(self):
        return FakeTransaction()


def test_normalize_playlist_name() -> None:
    assert playlist._normalize_playlist_name("Roadtrip") == "Roadtrip"
    assert playlist._normalize_playlist_name("Roadtrip.m3u") == "Roadtrip"
    assert playlist._normalize_playlist_name("Roadtrip.m3u8") == "Roadtrip"


@pytest.mark.parametrize("name", ["", ".", "..", "Nested/List"])
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

    assert changed == 3
    assert fields.loads_playlist_memberships(item_a.get("playlist_memberships")) == {
        "Other": 100,
        "Roadtrip": 200,
    }
    assert fields.loads_playlist_memberships(item_b.get("playlist_memberships")) == {
        "Roadtrip": 100,
    }
    assert fields.loads_playlist_memberships(item_c.get("playlist_memberships")) == {}

    assert item_a.store_calls == 1
    assert item_b.store_calls == 1
    assert item_c.store_calls == 1
    assert item_a.write_calls == 1
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

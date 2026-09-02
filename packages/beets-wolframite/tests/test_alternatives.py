from __future__ import annotations

from pathlib import Path
from typing import cast

import pytest
from beets.library import Library
from beets.ui import UserError

from beetsplug.wolframite import alternatives


class FakeItem:
    def __init__(self, item_id: int, path: Path, alt_path: Path | None = None) -> None:
        self.id = item_id
        self.path = path
        self.alt_path = alt_path

    def get(self, key: str, default=None):
        if key == "alt.lossy":
            return str(self.alt_path) if self.alt_path else default
        return default


class FakeLib:
    def __init__(self, directory: Path, items: list[FakeItem]) -> None:
        self.directory = directory
        self._items = items

    def items(self):
        return list(self._items)


def test_translated_entries_rewrites_existing_alternative_paths(tmp_path: Path) -> None:
    music_dir = tmp_path / "Music"
    source_playlist = tmp_path / "Playlists" / "Roadtrip.m3u"
    target_dir = music_dir / "Lossy"
    alt_path = target_dir / "Main/A/Artist/01. Song.opus"
    source_path = music_dir / "Main/A/Artist/01. Song.flac"

    source_playlist.parent.mkdir(parents=True)
    alt_path.parent.mkdir(parents=True)
    source_path.parent.mkdir(parents=True)
    alt_path.write_text("", encoding="utf-8")
    source_path.write_text("", encoding="utf-8")
    source_playlist.write_text("Main/A/Artist/01. Song.flac\n", encoding="utf-8")

    item = FakeItem(1, source_path, alt_path)
    entries = alternatives._translated_entries(
        source_playlist,
        music_dir,
        target_dir,
        alternatives._items_by_path(cast(Library, FakeLib(music_dir, [item]))),
        "lossy",
    )

    assert entries == ["Main/A/Artist/01. Song.opus"]


def test_translated_entries_skips_missing_alternative_files(tmp_path: Path) -> None:
    music_dir = tmp_path / "Music"
    source_playlist = tmp_path / "Playlists" / "Roadtrip.m3u"
    target_dir = music_dir / "Lossy"
    alt_path = target_dir / "Main/A/Artist/01. Song.opus"
    source_path = music_dir / "Main/A/Artist/01. Song.flac"

    source_playlist.parent.mkdir(parents=True)
    source_path.parent.mkdir(parents=True)
    source_path.write_text("", encoding="utf-8")
    source_playlist.write_text("Main/A/Artist/01. Song.flac\n", encoding="utf-8")

    item = FakeItem(1, source_path, alt_path)
    entries = alternatives._translated_entries(
        source_playlist,
        music_dir,
        target_dir,
        alternatives._items_by_path(cast(Library, FakeLib(music_dir, [item]))),
        "lossy",
    )

    assert entries == []


def test_sync_collection_playlists_writes_and_removes_playlists(
    tmp_path: Path,
    monkeypatch,
) -> None:
    music_dir = tmp_path / "Music"
    source_dir = music_dir / "Playlists"
    target_dir = music_dir / "Lossy"
    source_path = music_dir / "Main/A/Artist/01. Song.flac"
    alt_path = target_dir / "Main/A/Artist/01. Song.opus"

    source_dir.mkdir(parents=True)
    source_path.parent.mkdir(parents=True)
    alt_path.parent.mkdir(parents=True)
    source_path.write_text("", encoding="utf-8")
    alt_path.write_text("", encoding="utf-8")
    (source_dir / "Keep.m3u").write_text(
        "Main/A/Artist/01. Song.flac\n",
        encoding="utf-8",
    )
    (source_dir / "Drop.m3u").write_text("Missing.flac\n", encoding="utf-8")
    stale = target_dir / "Drop.m3u"
    stale.parent.mkdir(parents=True, exist_ok=True)
    stale.write_text(
        f"{alternatives._generated_marker('lossy')}\nstale\n",
        encoding="utf-8",
    )

    lib = FakeLib(music_dir, [FakeItem(1, source_path, alt_path)])
    monkeypatch.setattr(alternatives, "_alternative_directory", lambda _lib, _c: target_dir)
    monkeypatch.setattr(alternatives, "_playlist_dir", lambda _lib: source_dir)
    monkeypatch.setattr(
        alternatives,
        "_playlist_relative_to",
        lambda _lib, _path=None: music_dir,
    )

    count = alternatives.sync_collection_playlists(cast(Library, lib), "lossy")

    assert count == 1
    assert (target_dir / "Keep.m3u").read_text(encoding="utf-8") == (
        f"{alternatives._generated_marker('lossy')}\n"
        "Main/A/Artist/01. Song.opus\n"
    )
    assert not stale.exists()


def test_missing_source_directory_preserves_generated_targets(
    tmp_path: Path,
    monkeypatch,
) -> None:
    source_dir = tmp_path / "Missing"
    target_dir = tmp_path / "Lossy"
    target_dir.mkdir()
    target = target_dir / "Keep.m3u"
    target.write_text(
        f"{alternatives._generated_marker('lossy')}\nentry\n",
        encoding="utf-8",
    )
    lib = FakeLib(tmp_path / "Music", [])
    monkeypatch.setattr(alternatives, "_playlist_dir", lambda _lib: source_dir)
    monkeypatch.setattr(
        alternatives,
        "_alternative_directory",
        lambda _lib, _collection: target_dir,
    )

    assert alternatives.sync_collection_playlists(cast(Library, lib), "lossy") == 0
    assert target.exists()


def test_orphaned_generated_target_is_removed(tmp_path: Path, monkeypatch) -> None:
    source_dir = tmp_path / "Playlists"
    target_dir = tmp_path / "Lossy"
    source_dir.mkdir()
    target_dir.mkdir()
    target = target_dir / "Old.m3u"
    target.write_text(
        f"{alternatives._generated_marker('lossy')}\nentry\n",
        encoding="utf-8",
    )
    lib = FakeLib(tmp_path / "Music", [])
    monkeypatch.setattr(alternatives, "_playlist_dir", lambda _lib: source_dir)
    monkeypatch.setattr(
        alternatives,
        "_alternative_directory",
        lambda _lib, _collection: target_dir,
    )

    alternatives.sync_collection_playlists(cast(Library, lib), "lossy")

    assert not target.exists()


def test_symlinked_alternative_inside_collection_is_allowed(tmp_path: Path) -> None:
    music_dir = tmp_path / "Music"
    target_dir = music_dir / "Links"
    source_path = music_dir / "Main" / "Track.flac"
    target_path = target_dir / "Main" / "Track.flac"
    source_playlist = tmp_path / "Playlist.m3u"
    source_path.parent.mkdir(parents=True)
    target_path.parent.mkdir(parents=True)
    source_path.write_text("", encoding="utf-8")
    target_path.symlink_to(source_path)
    source_playlist.write_text("Main/Track.flac\n", encoding="utf-8")
    item = FakeItem(1, source_path, target_path)

    entries = alternatives._translated_entries(
        source_playlist,
        music_dir,
        target_dir,
        alternatives._items_by_path(cast(Library, FakeLib(music_dir, [item]))),
        "lossy",
    )

    assert entries == ["Main/Track.flac"]


def test_alternatives_refuses_to_overwrite_unowned_playlist(tmp_path: Path) -> None:
    path = tmp_path / "Roadtrip.m3u"
    path.write_text("manual\n", encoding="utf-8")

    with pytest.raises(UserError, match="unowned playlist"):
        alternatives._require_marker_or_missing(
            path,
            alternatives._generated_marker("lossy"),
        )

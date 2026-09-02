from __future__ import annotations

from types import SimpleNamespace

import pytest

from beetsplug.wolframite import templates


class FakeItem(SimpleNamespace):
    def get(self, key: str, default=None):
        return getattr(self, key, default)


@pytest.mark.parametrize(
    ("item", "expected"),
    [
        (FakeItem(track=2, tracktotal=12, disc=1, disctotal=1), "02"),
        (FakeItem(track=7, tracktotal=123, disc=1, disctotal=1), "007"),
        (FakeItem(track=3, tracktotal=12, disc=2, disctotal=2), "2-03"),
        (FakeItem(track=3, tracktotal=12, disc=2, disctotal=10), "02-03"),
        (FakeItem(track=3, tracktotal=12, disc=2, disctotal=0), "2-03"),
        (FakeItem(track=0, tracktotal=0, disc=0, disctotal=0), ""),
    ],
)
def test_tracknumber(item: FakeItem, expected: str) -> None:
    assert templates.tracknumber(item) == expected


@pytest.mark.parametrize(
    ("item", "expected"),
    [
        (FakeItem(year=2024, month=6, day=25), "2024-06-25"),
        (FakeItem(year=2024, month=6, day=0), "2024-06"),
        (FakeItem(year=2024, month=0, day=0), "2024"),
        (FakeItem(year=0, month=0, day=0), ""),
    ],
)
def test_date(item: FakeItem, expected: str) -> None:
    assert templates.date(item) == expected


@pytest.mark.parametrize(
    ("albumartist", "expected"),
    [
        ("The Beatles", "B"),
        ("A Perfect Circle", "P"),
        ("An Artist", "A"),
        ("Various Artists", "@"),
        ("Şuradan Buradan", "@"),
        ("2Pac", "0"),
        ("!!!", "0"),
        ("", "0"),
        ("ßeta", "S"),
        ("E\u0301clair", "0"),
        ("Éclair", "0"),
    ],
)
def test_initial(albumartist: str, expected: str) -> None:
    assert templates.initial(FakeItem(albumartist=albumartist)) == expected


@pytest.mark.parametrize(
    ("item", "expected"),
    [
        (FakeItem(albumtypes=[], albumartist="Artist"), ""),
        (FakeItem(albumtypes=["single"], albumartist="Artist"), "Singles"),
        (FakeItem(albumtypes=["ep"], albumartist="Artist"), "EPs"),
        (FakeItem(albumtypes=["dj-mix"], albumartist="Artist"), "Remixes"),
        (FakeItem(albumtypes=["remix"], albumartist="Artist"), "Remixes"),
        (FakeItem(albumtypes=["live"], albumartist="Artist"), "Live"),
        (FakeItem(albumtypes=["mixtape"], albumartist="Artist"), "Demos"),
        (FakeItem(albumtypes=["street"], albumartist="Artist"), "Demos"),
        (FakeItem(albumtypes=["demo"], albumartist="Artist"), "Demos"),
        (FakeItem(albumtypes=["interview"], albumartist="Artist"), "Streams"),
        (FakeItem(albumtypes=["broadcast"], albumartist="Artist"), "Streams"),
        (FakeItem(albumtypes=["compilation"], albumartist="Artist"), "Compilations"),
        (FakeItem(albumtypes=["compilation"], albumartist="Various Artists"), ""),
        (FakeItem(albumtypes="single; live", albumartist="Artist"), "Singles"),
        (FakeItem(albumtypes=["album"], albumartist="Artist", series=3), ""),
        (FakeItem(albumtypes=["deep"], albumartist="Artist"), ""),
        (FakeItem(albumtypes=["compilation"], albumartist="Şuradan Buradan"), ""),
    ],
)
def test_division(item: FakeItem, expected: str) -> None:
    assert templates.division(item) == expected


@pytest.mark.parametrize(
    ("text", "expected"),
    [
        ("Album", "Album"),
        ("Album.", "Album._"),
        ("Album. ", "Album._"),
        ("", ""),
    ],
)
def test_tdot(text: str, expected: str) -> None:
    assert templates.tdot(text) == expected

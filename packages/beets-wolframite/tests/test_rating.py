from __future__ import annotations

import mutagen.id3
import pytest

from beetsplug.wolframite import rating


class FakeTags(dict):
    def setall(self, key: str, frames: list[mutagen.id3.Frame]) -> None:
        assert len(frames) == 1
        self[key] = frames[0]

    def getall(self, key: str) -> list[mutagen.id3.Frame]:
        return [value for name, value in self.items() if name.startswith(f"{key}:")]

    def delall(self, key: str) -> None:
        for name in list(self):
            if name.startswith(f"{key}:"):
                del self[name]


class FakeMutagenFile:
    def __init__(self) -> None:
        self.tags = FakeTags()


@pytest.mark.parametrize(
    ("value", "expected"),
    [
        (-1, 0),
        (0, 0),
        (1, 1),
        (5, 5),
        (6, 5),
        (None, 0),
    ],
)
def test_clamp_stars(value, expected: int) -> None:
    assert rating.clamp_stars(value) == expected


@pytest.mark.parametrize(
    ("stars", "expected"),
    [
        (0, 0),
        (1, 51),
        (2, 102),
        (3, 153),
        (4, 204),
        (5, 255),
    ],
)
def test_stars_to_popm(stars: int, expected: int) -> None:
    assert rating.stars_to_popm(stars) == expected


@pytest.mark.parametrize(
    ("popm", "expected"),
    [
        (0, 0),
        (51, 1),
        (102, 2),
        (153, 3),
        (204, 4),
        (255, 5),
    ],
)
def test_popm_to_stars(popm: int, expected: int) -> None:
    assert rating.popm_to_stars(popm) == expected


@pytest.mark.parametrize(
    ("stars", "expected"),
    [
        (0, "0"),
        (1, "0.2"),
        (3, "0.6"),
        (4, "0.8"),
        (5, "1"),
    ],
)
def test_stars_to_fraction(stars: int, expected: str) -> None:
    assert rating.stars_to_fraction(stars) == expected


@pytest.mark.parametrize(
    ("fraction", "expected"),
    [
        ("0", 0),
        ("0.2", 1),
        ("0.6", 3),
        ("0.8", 4),
        ("1", 5),
    ],
)
def test_fraction_to_stars(fraction: str, expected: int) -> None:
    assert rating.fraction_to_stars(fraction) == expected


@pytest.mark.parametrize("value", ["invalid", "nan", "inf", "-inf"])
def test_fraction_to_stars_handles_invalid_values(value: str) -> None:
    assert rating.fraction_to_stars(value) == 0


def test_fraction_to_stars_clamps_range() -> None:
    assert rating.fraction_to_stars("2") == 5
    assert rating.fraction_to_stars("-1") == 0


def test_half_scale_ratings_round_consistently() -> None:
    assert rating.fraction_to_stars("0.5") == 3
    assert rating.percent_to_stars("50") == 3
    assert rating.popm_to_stars(128) == 3


@pytest.mark.parametrize(
    ("stars", "expected"),
    [
        (0, "0"),
        (1, "20"),
        (3, "60"),
        (4, "80"),
        (5, "100"),
    ],
)
def test_stars_to_percent(stars: int, expected: str) -> None:
    assert rating.stars_to_percent(stars) == expected


@pytest.mark.parametrize(
    ("percent", "expected"),
    [
        ("0", 0),
        ("20", 1),
        ("60", 3),
        ("80", 4),
        ("100", 5),
    ],
)
def test_percent_to_stars(percent: str, expected: int) -> None:
    assert rating.percent_to_stars(percent) == expected


def test_mp3_popularimeter_store_creates_popm_frame() -> None:
    style = rating.MP3PopularimeterStorageStyle("user@example.com")
    mutagen_file = FakeMutagenFile()

    style.store(mutagen_file, 4)

    frame = mutagen_file.tags["POPM:user@example.com"]
    assert isinstance(frame, mutagen.id3.POPM)
    assert frame.email == "user@example.com"
    assert frame.rating == 204
    assert frame.count == 0


def test_mp3_popularimeter_store_preserves_play_count() -> None:
    style = rating.MP3PopularimeterStorageStyle("user@example.com")
    mutagen_file = FakeMutagenFile()
    mutagen_file.tags["POPM:user@example.com"] = mutagen.id3.POPM(
        email="user@example.com",
        rating=51,
        count=42,
    )

    style.store(mutagen_file, 5)

    frame = mutagen_file.tags["POPM:user@example.com"]
    assert frame.rating == 255
    assert frame.count == 42


def test_mp3_popularimeter_fetch_reads_popm_frame() -> None:
    style = rating.MP3PopularimeterStorageStyle("user@example.com")
    mutagen_file = FakeMutagenFile()
    mutagen_file.tags["POPM:user@example.com"] = mutagen.id3.POPM(
        email="user@example.com",
        rating=204,
        count=42,
    )

    assert style.fetch(mutagen_file) == 4


def test_mp3_popularimeter_fetch_missing_frame() -> None:
    style = rating.MP3PopularimeterStorageStyle("user@example.com")
    mutagen_file = FakeMutagenFile()

    assert style.fetch(mutagen_file) is None


def test_mp3_popularimeter_reads_legacy_owner() -> None:
    style = rating.MP3PopularimeterStorageStyle(
        "wolframite",
        ["old@example.com"],
    )
    mutagen_file = FakeMutagenFile()
    mutagen_file.tags["POPM:old@example.com"] = mutagen.id3.POPM(
        email="old@example.com",
        rating=204,
        count=0,
    )

    assert style.fetch(mutagen_file) == 4


def test_mp3_popularimeter_discovers_unknown_owner() -> None:
    style = rating.MP3PopularimeterStorageStyle("wolframite")
    mutagen_file = FakeMutagenFile()
    mutagen_file.tags["POPM:other@example.com"] = mutagen.id3.POPM(
        email="other@example.com",
        rating=204,
        count=0,
    )

    assert style.fetch(mutagen_file) == 4


def test_mp3_popularimeter_prefers_new_owner_zero_rating() -> None:
    style = rating.MP3PopularimeterStorageStyle(
        "wolframite",
        ["old@example.com"],
    )
    mutagen_file = FakeMutagenFile()
    mutagen_file.tags["POPM:wolframite"] = mutagen.id3.POPM(
        email="wolframite",
        rating=0,
        count=0,
    )
    mutagen_file.tags["POPM:old@example.com"] = mutagen.id3.POPM(
        email="old@example.com",
        rating=255,
        count=0,
    )

    assert style.fetch(mutagen_file) == 0


def test_mp3_popularimeter_delete_writes_canonical_zero() -> None:
    style = rating.MP3PopularimeterStorageStyle("user@example.com")
    mutagen_file = FakeMutagenFile()
    mutagen_file.tags["POPM:user@example.com"] = mutagen.id3.POPM(
        email="user@example.com",
        rating=204,
        count=42,
    )

    style.delete(mutagen_file)

    frame = mutagen_file.tags["POPM:user@example.com"]
    assert frame.rating == 0
    assert frame.count == 42


def test_mp3_popularimeter_delete_preserves_foreign_owner() -> None:
    style = rating.MP3PopularimeterStorageStyle("wolframite")
    mutagen_file = FakeMutagenFile()
    mutagen_file.tags["POPM:wolframite"] = mutagen.id3.POPM(
        email="wolframite",
        rating=204,
        count=0,
    )
    mutagen_file.tags["POPM:player@example.com"] = mutagen.id3.POPM(
        email="player@example.com",
        rating=255,
        count=42,
    )

    style.delete(mutagen_file)

    assert mutagen_file.tags["POPM:wolframite"].rating == 0
    assert mutagen_file.tags["POPM:player@example.com"].count == 42


def test_normalized_rating_storage_style() -> None:
    style = rating.NormalizedRatingStorageStyle("RATING:user@example.com")

    assert style.serialize(4) == "0.8"
    assert style.deserialize("0.8") == 4
    assert style.deserialize(None) is None


def test_normalized_rating_reads_apetext_values() -> None:
    class APETextValue:
        def __str__(self) -> str:
            return "0.8"

    style = rating.NormalizedRatingStorageStyle("RATING:wolframite")

    assert style.deserialize(style.fetch({"RATING:wolframite": APETextValue()})) == 4


def test_mp4_rate_storage_style() -> None:
    style = rating.MP4RateStorageStyle()

    assert style.key == "rate"
    assert style.serialize(4) == "80"
    assert style.deserialize("80") == 4
    assert style.deserialize(None) is None


@pytest.mark.parametrize(
    ("stars", "stored"),
    [(0, 0), (1, 1), (2, 25), (3, 50), (4, 75), (5, 99)],
)
def test_asf_rating_storage(stars: int, stored: int) -> None:
    style = rating.ASFSharedUserRatingStorageStyle()

    assert style.serialize(stars) == stored
    assert style.deserialize(stored) == stars


def test_asf_rating_midpoint_rounds_up() -> None:
    style = rating.ASFSharedUserRatingStorageStyle()

    assert style.deserialize(13) == 2


def test_stars_media_field_constructs_media_field() -> None:
    field = rating.stars_media_field("user@example.com")

    assert field.out_type is int

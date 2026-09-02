"""Conventional star-rating tag support."""

from __future__ import annotations

import math
from collections.abc import Iterable

import mediafile
import mutagen.id3

DEFAULT_RATING_OWNER = "wolframite"


def clamp_stars(value) -> int:
    try:
        number = float(value or 0)
    except (TypeError, ValueError):
        return 0

    if not math.isfinite(number):
        return 0

    return max(0, min(5, math.floor(number + 0.5)))


def stars_to_popm(stars: int) -> int:
    return round(clamp_stars(stars) * 255 / 5)


def popm_to_stars(rating: int) -> int:
    scaled = max(0, min(255, int(rating or 0))) * 5 / 255
    return math.floor(scaled + 0.5)


def stars_to_fraction(stars: int) -> str:
    return f"{clamp_stars(stars) / 5:.6g}"


def fraction_to_stars(value) -> int:
    try:
        fraction = float(value or 0)
    except (TypeError, ValueError):
        return 0

    if not math.isfinite(fraction):
        return 0

    return clamp_stars(fraction * 5)


def stars_to_percent(stars: int) -> str:
    return str(clamp_stars(stars) * 20)


def percent_to_stars(value) -> int:
    try:
        percent = float(value or 0)
    except (TypeError, ValueError):
        return 0

    if not math.isfinite(percent):
        return 0

    return clamp_stars(percent / 20)


class MP3PopularimeterStorageStyle(mediafile.MP3StorageStyle):
    """Store stars in an ID3 POPM frame."""

    def __init__(
        self,
        owner: str = DEFAULT_RATING_OWNER,
        legacy_owners: Iterable[str] = (),
    ) -> None:
        self.owner = owner
        self.legacy_owners = tuple(legacy_owners)
        super().__init__(f"POPM:{owner}")

    def fetch(self, mutagen_file):
        for owner in (self.owner, *self.legacy_owners):
            try:
                frame = mutagen_file.tags[f"POPM:{owner}"]
            except KeyError:
                continue
            return popm_to_stars(frame.rating)

        frames = sorted(
            mutagen_file.tags.getall("POPM"),
            key=lambda frame: (frame.rating, frame.email),
            reverse=True,
        )
        if frames:
            return popm_to_stars(frames[0].rating)
        return None

    def store(self, mutagen_file, value) -> None:
        stars = clamp_stars(value)

        try:
            old_frame = mutagen_file.tags[self.key]
            count = getattr(old_frame, "count", 0)
        except KeyError:
            count = 0

        mutagen_file.tags.setall(
            self.key,
            [
                mutagen.id3.POPM(
                    email=self.owner,
                    rating=stars_to_popm(stars),
                    count=count,
                )
            ],
        )

    def delete(self, mutagen_file) -> None:
        self.store(mutagen_file, 0)


class NormalizedRatingStorageStyle(mediafile.StorageStyle):
    """Store stars as normalized 0.0..1.0 rating text."""

    def __init__(self, key: str, legacy_keys: Iterable[str] = ()) -> None:
        self.legacy_keys = tuple(legacy_keys)
        super().__init__(key)

    def fetch(self, mutagen_file):
        for key in (self.key, *self.legacy_keys):
            try:
                value = mutagen_file[key]
            except KeyError:
                continue
            if isinstance(value, list):
                return value[0] if value else None
            return str(value)

        ratings = []
        for key in mutagen_file.keys():
            if str(key).upper().startswith("RATING:"):
                value = mutagen_file[key]
                value = value[0] if isinstance(value, list) and value else value
                ratings.append((fraction_to_stars(value), str(key), value))
        if ratings:
            return max(ratings)[2]
        return None

    def delete(self, mutagen_file) -> None:
        self.store(mutagen_file, self.serialize(0))

    def serialize(self, value):
        return stars_to_fraction(clamp_stars(value))

    def deserialize(self, mutagen_value):
        if mutagen_value is None:
            return None
        return fraction_to_stars(mutagen_value)


class MP4RateStorageStyle(mediafile.MP4StorageStyle):
    """Store stars in the MP4 'rate' atom as 0..100 text."""

    def __init__(self) -> None:
        super().__init__("rate")

    def serialize(self, value):
        return stars_to_percent(clamp_stars(value))

    def deserialize(self, mutagen_value):
        if mutagen_value is None:
            return None
        return percent_to_stars(mutagen_value)


class ASFSharedUserRatingStorageStyle(mediafile.ASFStorageStyle):
    """Store ratings in the conventional ASF 0..99 field."""

    VALUES = (0, 1, 25, 50, 75, 99)

    def __init__(self) -> None:
        super().__init__("WM/SharedUserRating", as_type=int)

    def serialize(self, value):
        return self.VALUES[clamp_stars(value)]

    def deserialize(self, data):
        value = super().deserialize(data)
        try:
            rating = int(value)
        except (TypeError, ValueError):
            return 0
        return min(
            range(6),
            key=lambda stars: (abs(self.VALUES[stars] - rating), -stars),
        )


def stars_media_field(
    owner: str = DEFAULT_RATING_OWNER,
    legacy_owners: Iterable[str] = (),
) -> mediafile.MediaField:
    """Create a conventional cross-format star-rating field."""
    legacy_owners = tuple(
        legacy_owner for legacy_owner in legacy_owners if legacy_owner != owner
    )
    return mediafile.MediaField(
        MP3PopularimeterStorageStyle(owner, legacy_owners),
        MP4RateStorageStyle(),
        NormalizedRatingStorageStyle(
            f"RATING:{owner}",
            [f"RATING:{legacy_owner}" for legacy_owner in legacy_owners],
        ),
        ASFSharedUserRatingStorageStyle(),
        out_type=int,
    )

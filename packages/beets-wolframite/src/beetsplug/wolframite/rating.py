"""Conventional star-rating tag support."""

from __future__ import annotations

import confuse
import mediafile
import mutagen.id3
from beets import config

DEFAULT_RATING_OWNER = "wolframite"


def rating_owner() -> str:
    try:
        return config["musicbrainz"]["email"].as_str() or DEFAULT_RATING_OWNER
    except confuse.NotFoundError:
        return DEFAULT_RATING_OWNER


def clamp_stars(value) -> int:
    return max(0, min(5, int(value or 0)))


def stars_to_popm(stars: int) -> int:
    return round(clamp_stars(stars) * 255 / 5)


def popm_to_stars(rating: int) -> int:
    return round(max(0, min(255, int(rating or 0))) * 5 / 255)


def stars_to_fraction(stars: int) -> str:
    return f"{clamp_stars(stars) / 5:.6g}"


def fraction_to_stars(value) -> int:
    return round(float(value or 0) * 5)


def stars_to_percent(stars: int) -> str:
    return str(clamp_stars(stars) * 20)


def percent_to_stars(value) -> int:
    return round(float(value or 0) / 20)


class MP3PopularimeterStorageStyle(mediafile.MP3StorageStyle):
    """Store stars in an ID3 POPM frame."""

    def __init__(self, owner: str = DEFAULT_RATING_OWNER) -> None:
        self.owner = owner
        super().__init__(f"POPM:{owner}")

    def fetch(self, mutagen_file):
        try:
            frame = mutagen_file.tags[self.key]
        except KeyError:
            return None

        return popm_to_stars(frame.rating)

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
        if self.key in mutagen_file.tags:
            del mutagen_file.tags[self.key]


class NormalizedRatingStorageStyle(mediafile.StorageStyle):
    """Store stars as normalized 0.0..1.0 rating text."""

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


def stars_media_field(owner: str = DEFAULT_RATING_OWNER) -> mediafile.MediaField:
    """Create a conventional cross-format star-rating field."""
    return mediafile.MediaField(
        MP3PopularimeterStorageStyle(owner),
        MP4RateStorageStyle(),
        NormalizedRatingStorageStyle(f"RATING:{owner}"),
        out_type=int,
    )

"""Custom templating fields"""

from __future__ import annotations

import re
from typing import Any


def tracknumber(item: Any) -> str:
    """
    Expand to disc, then track number with proper padding.
    Do this with the proper amount of padding.
    """

    def padded(value: int, limit: int) -> str:
        return f"{value:0{len(str(limit))}d}"

    track_total = _get(item, "tracktotal", 0) or 0
    track = _get(item, "track", 0) or 0
    disc_total = _get(item, "disctotal", 0) or 0
    disc = _get(item, "disc", 0) or 0

    tracks = padded(track, track_total) if track_total > 99 else f"{track:02d}"

    if disc_total > 1:
        return f"{padded(disc, disc_total)}-{tracks}"

    return tracks


def date(item: Any) -> str:
    """
    Return the most specific available date as;
    - YYYY
    - YYYY-MM
    - YYYY-MM-DD.
    """
    year = _get(item, "year", 0) or 0
    month = _get(item, "month", 0) or 0
    day = _get(item, "day", 0) or 0

    if not year:
        return ""

    if not month:
        return str(year)

    if not day:
        return f"{year}-{month:02d}"

    return f"{year}-{month:02d}-{day:02d}"


def initial(item: Any) -> str:
    """Return album artist initial for top-level artist buckets."""
    albumartist = _get(item, "albumartist", "") or ""

    if albumartist in {"Various Artists", "Şuradan Buradan"}:
        return "@"

    sortable = re.sub(r"^(the|a|an) ", "", albumartist, flags=re.IGNORECASE)
    if not sortable:
        return "0"

    first = sortable[0].upper()

    if not (first.isascii() and first.isalnum()):
        return "0"

    if first.isnumeric():
        return "0"

    return first


def division(item: Any) -> str:
    """Return album subdivision based on series or album type."""
    series = _get(item, "series", "")
    if series:
        return str(series)

    albumtypes = _albumtypes(item)
    albumartist = _get(item, "albumartist", "") or ""

    # Check division folder in top down order
    if _has_albumtype(albumtypes, "single"):
        return "Singles"
    if _has_albumtype(albumtypes, "ep"):
        return "EPs"
    if _has_albumtype(albumtypes, "dj-mix") or _has_albumtype(albumtypes, "remix"):
        return "Remixes"
    if _has_albumtype(albumtypes, "live"):
        return "Live"
    if (
        _has_albumtype(albumtypes, "mixtape")
        or _has_albumtype(albumtypes, "street")
        or _has_albumtype(albumtypes, "demo")
    ):
        return "Demos"
    if _has_albumtype(albumtypes, "interview") or _has_albumtype(
        albumtypes, "broadcast"
    ):
        return "Streams"
    if "Various Artists" not in albumartist and _has_albumtype(
        albumtypes, "compilation"
    ):
        return "Compilations"

    return ""


def tdot(text: str) -> str:
    """Parse trailing dots in path components."""
    if text and text[-1] == ".":
        return f"{text}_"

    return text


def _get(item: Any, key: str, default: Any = None) -> Any:
    """Sane field fetcher function"""
    if hasattr(item, "get"):
        return item.get(key, default)

    return getattr(item, key, default)


def _albumtypes(item: Any) -> list[str]:
    """Sanitize album-types fetcher with list"""
    value = _get(item, "albumtypes", []) or []

    if isinstance(value, str):
        return [part.strip().lower() for part in value.split(";")]

    return [str(part).lower() for part in value]


def _has_albumtype(albumtypes: list[str], needle: str) -> bool:
    return any(needle in albumtype for albumtype in albumtypes)

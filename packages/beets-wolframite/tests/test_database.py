from __future__ import annotations

from pathlib import Path

import pytest
from beets.library import Item, Library

from beetsplug.wolframite import fields


def test_atomic_rolls_back_failed_group(tmp_path: Path) -> None:
    library = Library(
        path=tmp_path / "library.db",
        directory=str(tmp_path / "music"),
    )
    item = Item(path=tmp_path / "track.flac", title="Before")
    library.add(item)

    with pytest.raises(RuntimeError, match="stop"):
        with fields.atomic(library):
            item.title = "After"
            item.store()
            raise RuntimeError("stop")

    stored = library.get_item(item.id)
    assert stored is not None
    assert stored.title == "Before"

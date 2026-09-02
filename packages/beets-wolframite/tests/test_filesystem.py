from __future__ import annotations

from pathlib import Path

from beetsplug.wolframite import playlist


def test_atomic_write_replaces_symlink_without_touching_target(tmp_path: Path) -> None:
    target = tmp_path / "target.m3u"
    target.write_text("keep\n", encoding="utf-8")
    output = tmp_path / "output.m3u"
    output.symlink_to(target)

    changed = playlist.atomic_write_text(output, "new\n")

    assert changed
    assert not output.is_symlink()
    assert output.read_text(encoding="utf-8") == "new\n"
    assert target.read_text(encoding="utf-8") == "keep\n"

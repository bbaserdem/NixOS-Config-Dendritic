from __future__ import annotations

import argparse
import ast
import re
import site
from pathlib import Path

BEET = Path("/etc/profiles/per-user/wolframite/bin/beet").resolve()
WRAPPED = BEET.with_name(".beet-wrapped")

text = WRAPPED.read_text(encoding="utf-8")
match = re.search(
    r"functools\.reduce\(lambda k, p: site\.addsitedir\(p, k\), (\[.*?\]), site\._init_pathinfo\(\)\);",
    text,
    re.S,
)
if not match:
    raise SystemExit(f"Could not find Python site path list in {WRAPPED}")

for site_dir in ast.literal_eval(match.group(1)):
    site.addsitedir(site_dir)

from beets import config, library
from beets.util import syspath
from mediafile import MediaFile, UnreadableFileError


def empty(value):
    return value is None or value == "" or value == [] or value == ()


parser = argparse.ArgumentParser()
parser.add_argument("--field", action="append", required=True)
parser.add_argument("--query", action="append", default=[])
parser.add_argument("--only-empty-db", action="store_true")
parser.add_argument("--include-empty-file", action="store_true")
parser.add_argument("--apply", action="store_true")
args = parser.parse_args()

config.read()
lib = library.Library(
    config["library"].as_filename(), config["directory"].as_filename()
)

changed = 0
skipped = 0

for item in lib.items(args.query):
    try:
        media = MediaFile(syspath(item.path))
    except (UnreadableFileError, OSError) as exc:
        print(f"SKIP unreadable: {item} ({exc})")
        skipped += 1
        continue

    for field in args.field:
        old = item.get(field, with_album=False)
        new = getattr(media, field)

        if args.only_empty_db and not empty(old):
            continue
        if empty(new) and not args.include_empty_file:
            continue
        if old == new:
            continue

        print(f"{item}")
        print(f"  {field}: {old!r} -> {new!r}")

        if args.apply:
            item[field] = new
            item.store(fields=[field])

        changed += 1

print(
    f"{'APPLIED' if args.apply else 'DRY RUN'}: {changed} field changes, {skipped} skipped files"
)

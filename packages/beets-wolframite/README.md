# Beets Wolframite

Personal beets plugin for metadata fields, path templates, ratings, and
tag-backed playlists.

## Data ownership

Track tags are authoritative. Album copies of `collection`, `lossy`, `mood`,
and `introducer` are rebuilt only when every track has the same non-empty value.
Conflicting track values clear the album copy instead of overwriting tracks.

## Configuration

```yaml
wolframite:
  rating_owner: wolframite
  field_translations:
    - match: 'artist:"Oh Sees"'
      replacements:
        albumartist: Osees
```

Translations are validated before import, applied before duplicate detection,
and limited to writable metadata fields. Album-level replacements are applied
only when every track in the import task matches the rule.

`rating_owner` is stable across hosts. Existing POPM and `RATING:*` owners are
discovered when the canonical owner is absent and migrate when written.

## Commands

```console
beet propagate [-y] [--write|--nowrite] FIELD=VALUE... QUERY...
beet jsonpl generate NAME...
beet jsonpl generate-all
beet jsonpl save [--write|--nowrite] [--allow-empty] PLAYLIST.m3u
beet jsonpl sync-alternatives
```

`propagate` repairs album and item drift. Writing follows `import.write` by
default; `--nowrite` explicitly creates a disposable database-only change.

`jsonpl save` reads current membership JSON from each file before changing one
playlist, so unrelated remote playlists are preserved. Existing rank values are
kept when relative order is unchanged; additions use available numeric gaps.
Empty playlists require `--allow-empty` because they remove that membership from
every locally available item.

Generated playlists use ownership markers or manifests. Generation refuses to
replace an unowned M3U and stale cleanup removes only currently marked outputs.

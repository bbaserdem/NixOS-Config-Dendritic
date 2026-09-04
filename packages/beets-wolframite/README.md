# Beets Wolframite

Personal beets plugin for metadata fields, path templates, and playlist
synchronization for beets-alternatives collections.

## Fields

The database stores `collection`, `lossy`, `mood`, and `introducer` on both
items and albums.

`collection`, `mood`, and `introducer` also round-trip through media-file tags.
`lossy` is database-only because it controls generated alternatives subsets.

## Alternatives playlists

The packaged beets-alternatives plugin emits a collection-complete event after
every update. The Wolframite plugin then copies every main-library M3U into the
updated alternatives directory, removes unavailable tracks, and substitutes
the paths recorded in `alt.<collection>` for converted or linked files.

Generated alternatives playlists have collection-specific ownership markers.
Stale generated playlists are removed without deleting unrelated M3U files.

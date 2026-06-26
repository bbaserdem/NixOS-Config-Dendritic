# Beets

Beets is the music software that I use to organize [music](../usage/music.md).
While the main workflow for ingesting and synching is explained there,
the beets usage is a bit more complex.

## Local DB

A departure of the previous workflow; beets is set up such that
**database files are not shared; and are local only**.

This design decision was made because;

- Historically, syncing database has been fragile and introduce
sync conflicts constantly.
- We will have different hosts with different library subsets
all use beets, or not use beets at all.
- New workflow has library subsets, that may be present on hosts or not.
Which makes one db intractible, and the other solution of
compartmentalizing beets invocations between subdirectories is overcomplex.
- I actually *don't* care about the database.
The only concern I have about the db is to store my music metadata.
Which, should be file encoded from the get-go anyway.

> No one tool is a perfect fit for my workflows.
> The real reduction in maintenance burden comes not from reimplementing,
> but from utilizing whatever I can.

Beets is built to have data across two modalities, `track` and `album`.
Both information is stored in the sqlite database.
There is a metadata (`id3`) formalism for tracks, but not for albums.
Thus this induces a usecase constraint for any functionality I use.

- **Keep source of truth as tracks; edit information sparingly.**
- **No beets functionality should depend on album metadata**
- **All personal implementation should propagate album data to track data.**
- **All personal implementation should be written to tracks.**

The only usecase I had for database sync\ing is made obsolete with
being able to dispatch secrets selectively to beets.
Enables using listenbrainz play count syncing, so db syncing is moot.

# Todo

- [ ] Change convert command to new script; convert all lossless to flac with max compression.

## Organization

Most of the beets config lies inside the configuration of user `wolframite`.
The config is split between various files;

- `beets.nix`: Main setting entry point.
- `files.nix`: File organization setup.
- `art.nix`: Plugins/settings dealing with album artwork, and extra assets.
- `convert.nix`: Dispatch the file format conversion formalism.
- `metadata.nix`: Functionality metadata manipulation.
- `musicbrainz.nix`: Sets up settings for MB import and library export.
(Credentials are supplied by `sops-nix`.)
- `package.nix`: Package definition with overrides of custom packages.
- `playlists.nix`: Configuration for smart playlist generation.
- `convert.nix`: File conversion plugin settings.
Links the local audio script (`audman`) to beets, so they are used for transcoding.

## Tags

There are a few freeform tags that I use, which are consumed by beets.
The package `beets-wolframite` contains these fields, so they are written
to file tags.

### Collection

`collection: <str>`, items with this get put into the specific subfolder.
This is useful; as the library can be split into a smaller *core*
that can be synced around, but I end up not having to delete files.

### Lossy

`lossy: <bool>`, items that are not `archive` but are `lossy` will be transcoded
to a `Lossy` subdirectory.
This directory is ignored by beets.
Main usage is to create a low-memory subset library that can be synced
to memory-crucial locations; if they don't use `mpd`. (`su-ana`, `erlik`)

### Introducer

`introducer: <str>` Either denotes who gave me the music,
or where I found the music.

### Mood

`mood: listOf <str>` An internal genre for me;
mainly for curating playlists.
Currently used moods are;

| Mood Name | Description |
|:--- |:--- |
| `instrumental` | Songs with no songs |
| `microtonal` | Non-western music scales |
| `affirmation` | Chill, zen philosophy, self-care coded songs. |
| `heavy` | Heavier (metal, base, dubstep) songs |
| `turkish` | Turkish songs |
| `japanese` | Japanese songs |
| `ambient` | Ambient, drone type songs |
| `electronic` | Mainly electronically produced music |
| `space` | Space related tracks |
| `trippy` | Psychedelic tracks |
| `gag` | Funny, lighthearted, self-aware tracks. |
| `game` | Video game related music. |


## Plugin

I use my personal plugin `beets-wolframite` to manage several functionality.

### Fields

The plugin defines some template fields;

- `tracknumber`
- `trackdate`, `albumdate`
- `artistinitial`
- `division`, `albumdivision`

### Functions

The plugin defines some custom functions;

- `%tdot`; Remove trailing dot (`.<FILE> and <FILE>` clash on `exFAT`).

### Commands

- `jsonpl`; Save and load playlists from a json tag in track metadata.

### Hooks

- `field_translations`; Define translations that will normalize tags at import time.
- `alternatives`; Hooks into `beet-alternatives` to produce playlist copies.

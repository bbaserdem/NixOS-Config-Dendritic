# Music Organization

Music organization in this repo;

## Todo

- [ ] Import all albums I have been missing.
- [ ] Modify `lossy` tag, and create alternate library.
- [ ] Clean, and maybe reimport musicbrainz tags; upload collection to MB.
- [ ] Split music library into main and archive.
- [ ] Overhaul lyrics.

## Workflow

Music coming into the library follows a set processing pipeline;

1. Get tagged, with musicbrainz `picard`.
2. Import into `beets` library.
3. Assign tags when needed.

## Library Structure

The library is divided into several subfolders;

- `Untagged`: Where music that's not tagged, and not archived reside.
- `Main`: The main music library; standart section that should be commonly available.
- `Archive`: Archival music library, not to be synced to every computer.
- `Lossy`: Alternative subset that is lossy files; for disk space limited usage.

## Music Importing

TODO: This part; streamrip etc.

## Transcoding

We have our own cli tool for transcoding.

## Beets

[Beets](../software/beets.md) is the main tagger/organizer application that I use.
It's a tagger and a database tool.

Beets configuration carries the library structure;
As of now, it should look like the following;

```
~/Music
  Unsorted
  Main
    A
    B
    ...
    K
        King Gizzard
            <Albums>
  Archive
  Lossy
  <Playlists>m3u
```

### Importing

`beet import <dir>` should be straightforward, make sure files are tagged.

### Tagging

I have several personal tags for hand curation; specifically

- `introducer`: Metadata, how I obtained the music.
- `mood`: A personal genre tag.
- `lossy`: Whether to encode this file to the lossy subset.
- `collection`: Subdirectory to put under.

Due to internal issues; for these tags it's not straightforward
to propagate album based beet tags to file tags.
We have a custom workflow for this;

```
# Don't use edit command
beet modify --album mood="heavy; instrumental" album:"The Eldar"
beet propagate mood="heavy; instrumental" album:"The Eldar"
```

- `beet write`: Writes database tags to tracks. Takes in `-p` flag for preview.
- `beet update`: Updates database from file tags. Takes in `-p` flag for preview.

### Playlists

For playlists; I keep a record of the playlists in my file tags.

To save a playlist in my track tags; issue the command:

```
beet jsonpl save ~/Music/<Playlist>.m3u
```

This will modify the json string of each track; writing `{"playlist": 100*<order>}`.

The playlist can be curated by editing the playlist ordering by hand.

To recover playlists; use the following command;

```
beet jsonpl generate <Playlist>
# Or do all
beet jsonpl generate-all
```

### Lossy subset

For phone and work computer, I only sync a lossy subset.
To refresh the list;

```
# Set album for lossy encoding
beet propagate lossy=true album:"<Album>"
# Refresh lossy playlist
beet alt update lossy --create
```

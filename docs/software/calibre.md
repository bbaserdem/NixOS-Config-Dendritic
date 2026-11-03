# Calibre

This is a description of how Calibre is used to organize reading media across my computers.

Calibre is a horribly designed application from a user standpoint.
Every config file is overwritten with state data, and it's very fragmented.
Thus, declarative management of calibre is impossible.
Unfortunately, calibre is the best book management software with no alternatives,
hence will need to be used.

## Setup

Calibre needs a library; and it's pointed to `$XDG_DOCUMENTS_DIR/Books`.
The folder is chosen to be synced with syncthing; and excludes some runtime data.
Just pointing the library to this folder on first launch should be fine.

## Settings

I imperatively declare these settings;

- I have custom fields; `#edition` and `#genre`.
- `genre` and `series` labels is marked as hierarchical in `Look & Feel/Tag browser`.
- I limit metadata import fields to usually just _comments_.
- `Amazon.com` and `Openbook Library` are two metadata sources I allow.
  (I find the google metadata is very dirty.)

## Tags

To organize the library; I use the **genre** label.
The label is hierarchical; the first layer uses one of three distinctions;

- Fiction
- Non-Fiction
- Textbook

Genre is categorical; so these open up the tags.
And the rest are a bit self-explanatory.

### Naming

I use KOReader on my BOOX device to read my books.
It's not a seamless experience by any stretch of the imagination, but alas.

Calibre uses naming script to export files to devices.
To work with KOReader, I have the following naming scheme;

(The config file for this is written to every time the BOOX is accessed by calibre;
and resides in `$XDG_CONFIG_HOME/calibre/mt_devices.json`.
Horrible, horrible design choice. As expected of calibre.)

```
program:
  g = first_non_empty(list_item(field('#genre'), 0, ','), 'Unsorted');
  shelf = re(g, '\..*$', '');
  if field('series') then
    main = re(field('series'), '\..*$', '');
    n = format_number($series_index, '{0:g}');
    n = if $series_index <# 10 then strcat('0', n) else n fi;
    strcat(shelf, '/', main, '/', n, ' - ', $title)
  else
    strcat(shelf, '/', $author_sort, '/', $title)
  fi
```

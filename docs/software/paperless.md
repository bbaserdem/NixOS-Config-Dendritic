# Paperless

`paperless-ngx` is a document management system.

## TODO

- [ ] Figure out port workflow
- [ ] Figure out injestion folder symlinks
- [ ] Metadata backup timer

## Setup 

Paperless is composed of approximately three parts.

| Subdirectory | Contents | Safe to sync? |
|:--- |:--- |:--- |
| `mediaDir` | Uploaded files, OCR'd files | Yes |
| `dataDir` | SQLite database | No |
| `consumptionDir` | Files to be outo-injested | No |

The database is SQLite, but kept open by `paperless` so it's corruptable.
The only safe way to back up is to periodically dump the database.
This is done via a timer that runs `paperless-ngx document_exporter <path>`.

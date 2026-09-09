# Audman (Audio Manager)

One app for conversion needs, rather than multiple scripts.

Path-based conversions encode and validate files in a temporary directory before
installing them. Replaced source files are preserved under:

```text
$XDG_STATE_HOME/audman/backups/<YYYYMMDD-HHMMSS>-<target>/
```

`XDG_STATE_HOME` defaults to `~/.local/state`. Directory targets retain their relative
directory structure inside the backup. Pass `--no-backup` to remove converted sources
instead.

Existing outputs are rejected by default. Pass `--force` to atomically replace a
regular output file after conversion succeeds. Symbolic links are always rejected.

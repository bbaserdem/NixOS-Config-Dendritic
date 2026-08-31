# Audman (Audio Manager)

One app for conversion needs, rather than multiple scripts.

Path-based conversions display aggregate progress and preserve replaced source files under:

```text
~/.cache/audman-backup/<YYYYMMDD-HHMMSS>-<target>/
```

Directory targets retain their relative directory structure inside the backup. Pass
`--no-backup` to remove converted sources instead.

#!/usr/bin/env bash
# Batch encode to lossy format

if [ -n "${1}" ] ; then
    input_dir="${1}"
else
    input_dir="$(pwd)"
fi
[ -d "${input_dir}" ] || echo "Directory ${input_dir} does not exist, or is not a directory."

# Run scripts on all files under these directories
find "${input_dir}" -type f -name '*.flac' | parallel audio-convert_flac-2-opus  '{}'
find "${input_dir}" -type f -name '*.mp3'  | parallel audio-convert_mp3-2-opus   '{}'
find "${input_dir}" -type f -name '*.m4a'  | parallel audio-convert_m4a-2-opus   '{}'
find "${input_dir}" -type f -name '*.ogg'  | parallel audio-convert_ogg-2-opus   '{}'

# Alert that conversion is done
notify-send "Lossy re-encoding is done!" -i dialog-info

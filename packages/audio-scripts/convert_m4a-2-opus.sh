#!/usr/bin/env bash
# Convert m4a files to opus format

input_file="${1}"
downl_dir="$(xdg-user-dir DOWNLOAD)"
[ -z "${downl_dir}" ] && downl_dir="${HOME}/Downloads"
backup_dir="${downl_dir}/M4aToOpus-backup"
mkdir --parents "${backup_dir}"

# Guard
[ -f "${input_file}" ] || exit
[ "${input_file:(-4)}" == '.m4a' ] || exit

# Get new filename by removing the last 4 letters
this_name="$(basename "${input_file}")"
this_dir="$(dirname "${input_file}")"
output_file="${this_dir}/${this_name::-4}.opus"
backup_file="${backup_dir}/${this_name}"

# Do conversion, and if successful move old file to backup
ffmpeg \
  -i "${input_file}" \
  -codec:a libopus -b:a 192k -vbr on \
  "${output_file}" && \
  mv "${input_file}" "${backup_file}"

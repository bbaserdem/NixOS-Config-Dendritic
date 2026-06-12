#!/usr/bin/env bash
# Claude Code status line — receives session JSON on stdin.
set -euo pipefail

input=$(cat)

field() { jq -r "$1" <<<"$input"; }

model=$(field '.model.display_name // "?"')
proj=$(field '.workspace.project_dir // .workspace.current_dir // "."')
used=$(field '.context_window.used_percentage // 0')
in_tok=$(field '.context_window.total_input_tokens // 0')
ctx=$(field '.context_window.context_window_size // 0')
cost=$(field '.cost.total_cost_usd // 0')
dur_ms=$(field '.cost.total_duration_ms // 0')
five=$(field '.rate_limits.five_hour.used_percentage // empty')
week=$(field '.rate_limits.seven_day.used_percentage // empty')

reset=$'\033[0m' bold=$'\033[1m' dim=$'\033[2m'
red=$'\033[31m' green=$'\033[32m' yellow=$'\033[33m'
blue=$'\033[34m' cyan=$'\033[36m'

proj_name=$(basename "$proj")

git_seg=""
branch=$(git -C "$proj" --no-optional-locks branch --show-current 2>/dev/null || true)
if [ -n "$branch" ]; then
  dirty=$( (git -C "$proj" --no-optional-locks status --porcelain 2>/dev/null || true) | wc -l | tr -d ' ')
  flag=""
  if [ "$dirty" -gt 0 ]; then flag="${yellow} ●${dirty}${reset}"; fi
  git_seg="  ${green} ${branch}${reset}${flag}"
fi

pct=$(awk -v p="$used" 'BEGIN { printf "%d", p + 0.5 }')
tok=$(awk -v a="$in_tok" -v b="$ctx" 'BEGIN { printf "%.0fk/%.0fk", a/1000, b/1000 }')
cost_fmt=$(awk -v c="$cost" 'BEGIN { printf "$%.2f", c }')

secs=$(( dur_ms / 1000 ))
if [ "$secs" -ge 3600 ]; then
  dur_fmt="$(( secs / 3600 ))h$(( secs % 3600 / 60 ))m"
else
  dur_fmt="$(( secs / 60 ))m$(( secs % 60 ))s"
fi

ctx_color=$green
if [ "$pct" -ge 80 ]; then ctx_color=$red
elif [ "$pct" -ge 60 ]; then ctx_color=$yellow
fi

width=20
filled=$(( pct * width / 100 ))
if [ "$filled" -gt "$width" ]; then filled=$width; fi
bar=""
for (( i = 0; i < width; i++ )); do
  if (( i < filled )); then bar+="█"; else bar+="░"; fi
done

rate_seg=""
if [ -n "$five" ]; then
  rate_seg+="  ${dim} 5h $(awk -v p="$five" 'BEGIN { printf "%d", p }')%${reset}"
fi
if [ -n "$week" ]; then
  rate_seg+="  ${dim} 7d $(awk -v p="$week" 'BEGIN { printf "%d", p }')%${reset}"
fi

printf '%s\n' "${bold}${cyan} ${model}${reset}  ${blue} ${proj_name}${reset}${git_seg}"
printf '%s\n' "${ctx_color} ${pct}% ${bar}${reset} ${dim}${tok}${reset}  ${yellow} ${cost_fmt}${reset}  ${dim} ${dur_fmt}${reset}${rate_seg}"

#!/usr/bin/env bash
# The client's storage folder (workspace). Saved once, read by every script through _env.sh.
# Usage:
#   workspace.sh status          print the saved path (exit 0) or "not set" (exit 1)
#   workspace.sh get             print the path only (exit 1 if not set)
#   workspace.sh set FOLDER      FOLDER is the folder the client picked (their ChatGPT project folder or any folder).
#                                The workspace becomes FOLDER/xhs-studio (created). The path is saved in
#                                ~/.config/xhs-studio/workspace, outside the skill folder, so a skill update never loses it.
#   workspace.sh clear           forget the saved path (files in the workspace are NOT deleted)
set -euo pipefail
export XHS_ENV_OPTIONAL=1
ptr="${XDG_CONFIG_HOME:-$HOME/.config}/xhs-studio/workspace"
cmd="${1:-status}"
case "$cmd" in
  status|get)
    cur=""; [ -n "${XHS_HOME:-}" ] && cur="$XHS_HOME"
    [ -z "$cur" ] && [ -s "$ptr" ] && cur="$(head -1 "$ptr")"
    if [ -z "$cur" ]; then [ "$cmd" = status ] && echo "workspace: not set"; exit 1; fi
    if [ "$cmd" = get ]; then echo "$cur"; else
      echo "workspace: $cur"; [ -d "$cur" ] && echo "folder exists" || echo "WARNING: folder is missing (drive unplugged or moved?)"; fi ;;
  set)
    f="${2:?usage: workspace.sh set FOLDER}"
    case "$f" in "~"*) f="$HOME${f#\~}";; esac
    [ -d "$f" ] || { echo "folder does not exist: $f (ask the client to create it, or pick another)"; exit 1; }
    f="$(cd "$f" && pwd)"
    case "$f" in */xhs-studio) ws="$f";; *) ws="$f/xhs-studio";; esac
    mkdir -p "$ws/jobs" "$ws/log" "$ws/state" "$ws/footage-in"
    [ -w "$ws" ] || { echo "folder is not writable: $ws"; exit 1; }
    mkdir -p "$(dirname "$ptr")"; printf '%s\n' "$ws" > "$ptr"
    echo "workspace saved: $ws"
    echo "Every script now reads it. Layout: profile.json, jobs/, log/, state/, footage-in/ (put raw footage here or anywhere)." ;;
  clear) rm -f "$ptr"; echo "workspace path forgotten (no files deleted)";;
  *) echo "usage: workspace.sh status|get|set FOLDER|clear"; exit 1;;
esac

#!/usr/bin/env bash
# Start ONE browser session on the client's own Chrome (Agent Window) through bsk.
# Usage: bsk-start.sh "<task name>" [--show]
# Prints ONLY the bare session id (for example "rdjq") on stdout. Exit 1 + reason on stderr.
# Default: the Agent Window opens in the background. --show brings it to the front; use it
# only when the client is watching, or must sign in / approve the form.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_env.sh"
show=0; task="xhs-studio"
for a in "$@"; do if [ "$a" = "--show" ]; then show=1; else task="$a"; fi; done
[ -n "$BSK_BIN" ] || { echo "bsk is not installed. Run scripts/doctor.sh and follow the bsk install step." >&2; exit 1; }
# One session at a time.
if [ -f "$XHS_STATE/session.id" ]; then
  old="$(cat "$XHS_STATE/session.id")"
  if "$BSK_BIN" session list 2>/dev/null | grep -q "$old"; then
    echo "A session ($old) is still open. Run scripts/bsk-stop.sh first." >&2; exit 1
  fi
  rm -f "$XHS_STATE/session.id"
fi
browser_label=""
if [ -f "$XHS_PROFILE" ]; then
  browser_label="$(python3 -c 'import json,sys;print((json.load(open(sys.argv[1])).get("system") or {}).get("browser_label") or "")' "$XHS_PROFILE" 2>/dev/null || true)"
fi
args=(session start --name "xhs-studio: $task" --json)
[ "$show" = 1 ] || args+=(--no-focus)
[ -n "$browser_label" ] && args+=(--browser "$browser_label")
out="$("$BSK_BIN" "${args[@]}" 2>&1)" || { echo "bsk session start failed: $out" >&2
  echo "Hint: is Chrome open with the BrowserSkill extension on? Run: bsk doctor" >&2; exit 1; }
sid="$(python3 -c 'import sys,json;print(json.loads(sys.argv[1])["session_id"])' "$out" 2>/dev/null)" || {
  echo "bsk session start gave no session id: $out" >&2; exit 1; }
echo "$sid" > "$XHS_STATE/session.id"
echo "$sid"

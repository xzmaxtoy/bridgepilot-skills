#!/usr/bin/env bash
# Ask before any automatic action. Exit 0 = allowed, exit 10 = not allowed (reason on stdout).
# Usage: guard.sh publish|comments|dms
# Allowed only if: the client turned that switch ON in profile.json, the kill switch is off,
# and there is no platform-warning stop. Anything else = prepare the draft and stop.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_env.sh"
sw="${1:?usage: guard.sh publish|comments|dms}"
case "$sw" in publish|comments|dms) ;; *) echo "unknown switch $sw"; exit 10 ;; esac
[ -f "$XHS_STATE/PAUSED" ]  && { echo "kill switch is ON"; exit 10; }
[ -f "$XHS_STATE/STOPPED" ] && { echo "platform warning stop is active"; exit 10; }
[ -f "$XHS_PROFILE" ] || { echo "no profile.json: first-run interview not done"; exit 10; }
val="$(python3 - "$XHS_PROFILE" "$sw" <<'PY'
import json, sys
p = json.load(open(sys.argv[1]))
a = p.get("automation") or {}
key = {"publish": "auto_publish", "comments": "auto_reply_comments", "dms": "auto_reply_dms"}[sys.argv[2]]
print("true" if a.get(key) is True else "false")
PY
)"
[ "$val" = "true" ] || { echo "switch auto-$sw is OFF in profile.json"; exit 10; }
exit 0

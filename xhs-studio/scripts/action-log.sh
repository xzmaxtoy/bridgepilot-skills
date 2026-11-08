#!/usr/bin/env bash
# Append one line to the action log. Every automatic action MUST be logged (before and after).
# Usage: action-log.sh <type> <mode: auto|manual|none> <detail text>
#   type examples: publish-attempt, publish-done, comment-reply, dm-reply, warning-stop, kill-switch-on
# Log file: $XHS_HOME/log/actions.jsonl (one JSON object per line, UTC time).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_env.sh"
python3 - "$XHS_LOG/actions.jsonl" "${1:?type}" "${2:-none}" "${3:-}" <<'PY'
import json, sys, datetime
path, typ, mode, detail = sys.argv[1:5]
rec = {"ts": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
       "type": typ, "mode": mode, "detail": detail}
with open(path, "a", encoding="utf-8") as f:
    f.write(json.dumps(rec, ensure_ascii=False) + "\n")
print(json.dumps(rec, ensure_ascii=False))
PY

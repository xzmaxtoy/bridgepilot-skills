#!/usr/bin/env bash
# Always stop the session, also after a failure. Close the tab first (see references/browser-runtime.md).
# Usage: bsk-stop.sh [session-id]      (no id = stop all sessions)
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_env.sh"
[ -n "$BSK_BIN" ] || { echo "bsk not installed"; exit 1; }
if [ -n "${1:-}" ]; then "$BSK_BIN" session stop "$1" || true; else "$BSK_BIN" session stop --all || true; fi
rm -f "$XHS_STATE/session.id"
echo "--- bsk session list (must show no session) ---"
"$BSK_BIN" session list

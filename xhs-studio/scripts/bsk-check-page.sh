#!/usr/bin/env bash
# Run after EVERY navigate. On its own line, never piped (a pipe hides the exit code).
# Usage: bsk-check-page.sh <session-id>
# Exit 0 = normal page.
# Exit 3 = sign-in / 2FA / captcha wall: hand it to the client (bsk request-help), then check again.
# Exit 4 = platform WARNING ("too frequent", "try later", restriction): auto actions are
#          switched off at once (state/STOPPED); report to the client; do not retry.
# Exit 1 = the check itself failed.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_env.sh"
sid="${1:?usage: bsk-check-page.sh <session-id>}"
[ -n "$BSK_BIN" ] || { echo "bsk not installed" >&2; exit 1; }
js='JSON.stringify({href:location.href,title:document.title,text:((document.querySelector("main")||document.body).innerText||"").slice(0,3500)})'
out="$("$BSK_BIN" evaluate --session "$sid" "$js" 2>&1)" || { echo "check failed: $out" >&2; exit 1; }
res="$(printf '%s' "$out" | python3 "$here/classify_page.py")"; code=$?
echo "$res"
if [ "$code" = 4 ]; then
  date -u +%Y-%m-%dT%H:%M:%SZ > "$XHS_STATE/STOPPED"
  echo "$res" >> "$XHS_STATE/STOPPED"
  bash "$here/action-log.sh" warning-stop none "$res" >/dev/null 2>&1 || true
  echo "STOP: platform warning. All auto actions are off until the client clears it (scripts/kill-switch.sh clear-warning)." >&2
fi
exit $code

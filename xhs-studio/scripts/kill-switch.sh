#!/usr/bin/env bash
# One-command kill switch for ALL automatic actions (publish, comment replies, DM replies).
#   kill-switch.sh on             pause everything now (drafts and reading still work)
#   kill-switch.sh off            resume (the three switches in profile.json still decide)
#   kill-switch.sh status         show pause state, warning stop and the three switches
#   kill-switch.sh clear-warning  clear a platform-warning stop after the client has looked
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_env.sh"
case "${1:-status}" in
  on)  date -u +%Y-%m-%dT%H:%M:%SZ > "$XHS_STATE/PAUSED"
       bash "$here/action-log.sh" kill-switch-on none "paused by client" >/dev/null
       echo "PAUSED: no automatic action will run. The skill prepares drafts only." ;;
  off) rm -f "$XHS_STATE/PAUSED"
       bash "$here/action-log.sh" kill-switch-off none "resumed by client" >/dev/null
       echo "Resumed. Only switches set to true in profile.json may act." ;;
  clear-warning) rm -f "$XHS_STATE/STOPPED"
       bash "$here/action-log.sh" warning-cleared none "cleared by client" >/dev/null
       echo "Warning stop cleared." ;;
  status)
       [ -f "$XHS_STATE/PAUSED" ]  && echo "kill switch: ON (paused since $(head -1 "$XHS_STATE/PAUSED"))" || echo "kill switch: off"
       [ -f "$XHS_STATE/STOPPED" ] && echo "warning stop: ACTIVE ($(tr '\n' ' ' < "$XHS_STATE/STOPPED"))" || echo "warning stop: none"
       for s in publish comments dms; do
         if bash "$here/guard.sh" "$s" >/dev/null 2>&1; then echo "auto-$s: ALLOWED"; else echo "auto-$s: not allowed ($(bash "$here/guard.sh" "$s" 2>&1 | head -1))"; fi
       done ;;
  *) echo "usage: kill-switch.sh on|off|status|clear-warning"; exit 1 ;;
esac

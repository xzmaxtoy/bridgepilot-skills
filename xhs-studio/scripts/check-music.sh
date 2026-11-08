#!/usr/bin/env bash
# Offline dependency/readiness check. Authentication and retrieval are guided in SETUP B6a.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
export XHS_ENV_OPTIONAL=1
. "$here/_env.sh"
selected=none; ready=false
if [ -n "${XHS_PROFILE:-}" ] && [ -f "$XHS_PROFILE" ]; then
  selected="$(python3 -c 'import json,sys; print((json.load(open(sys.argv[1])).get("final_cut") or {}).get("music_source", "none"))' "$XHS_PROFILE")" || exit 1
  ready="$(python3 -c 'import json,sys; print(str((json.load(open(sys.argv[1])).get("system") or {}).get("music_catalog_ready") is True).lower())' "$XHS_PROFILE")" || exit 1
fi
if [ "$selected" != catalog ]; then
  echo "OK       catalog music          not selected; no HeyGen helper or sign-in required"
  exit 0
fi
helper="${HEYGEN_BIN:-}"
if [ -z "$helper" ]; then
  helper="$(command -v heygen 2>/dev/null || true)"
  [ -n "$helper" ] || helper="$HOME/.local/bin/heygen"
fi
if [ ! -x "$helper" ]; then
  echo "MISSING  heygen helper          install from https://developers.heygen.com/cli (SETUP B6a)"
  exit 1
fi
version="$("$helper" --version 2>&1)"; rc=$?
if [ "$rc" != 0 ] || ! python3 - "$version" <<'PY'
import re, sys
m = re.search(r"\b(?:v)?(\d+)\.(\d+)\.(\d+)", sys.argv[1])
sys.exit(0 if m and tuple(map(int, m.groups())) >= (0, 3, 0) else 1)
PY
then
  echo "MISSING  heygen helper          could not verify version 0.3.0+; follow installed media-use compatibility guidance"
  exit 1
fi
echo "OK       heygen helper          $version"
if [ "$ready" != true ]; then
  echo "MISSING  catalog access         run npx hyperframes auth status; guide client sign-in if needed, then prove free track retrieval (SETUP B6a)"
  exit 1
fi
echo "OK       catalog access         last retrieval verified; recheck auth before the next catalog use"

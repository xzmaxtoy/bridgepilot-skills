#!/usr/bin/env bash
# Check every dependency of xhs-studio and say how to fix what is missing.
# Usage: doctor.sh            exit 0 = all required parts OK, exit 1 = something MISSING
# Each line: OK / WARN / MISSING + a one-line fix. Full list and commands: DEPENDENCIES.md
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
export XHS_ENV_OPTIONAL=1
. "$here/_env.sh"
bad=0
ok()   { printf 'OK       %-22s %s\n' "$1" "$2"; }
warn() { printf 'WARN     %-22s %s\n' "$1" "$2"; }
miss() { printf 'MISSING  %-22s %s\n' "$1" "$2"; bad=1; }
os="$(uname -s)"
case "$os" in Darwin) osn=mac;; Linux) osn=linux;; MINGW*|MSYS*|CYGWIN*) osn=windows;; *) osn=other;; esac
ok "system" "$os (scripts need bash; on Windows use Git Bash or WSL, see DEPENDENCIES.md)"

# Node + npm (HyperFrames needs Node 22 or newer)
if command -v node >/dev/null 2>&1; then
  v="$(node -v)"; major="${v#v}"; major="${major%%.*}"
  if [ "$major" -lt 22 ]; then miss "node" "$v is too old. HyperFrames needs Node 22 or newer. Install from https://nodejs.org (macOS: brew install node@22)"
  else ok "node" "$v"; fi
else miss "node" "not installed. Install Node.js 22 or newer from https://nodejs.org (macOS: brew install node@22)"; fi
if command -v npm >/dev/null 2>&1; then ok "npm" "$(npm -v)"; else miss "npm" "comes with Node.js"; fi

# ffmpeg / ffprobe
for t in ffmpeg ffprobe; do
  if command -v $t >/dev/null 2>&1; then ok "$t" "$($t -version 2>/dev/null | head -1 | cut -c1-40)"
  else
    case $osn in mac) h="brew install ffmpeg";; linux) h="sudo apt install ffmpeg";; windows) h="winget install Gyan.FFmpeg";; *) h="install ffmpeg from https://ffmpeg.org";; esac
    miss "$t" "not installed. $h"
  fi
done

# python3 (small scripts: cutdown, lint, profile check)
if command -v python3 >/dev/null 2>&1; then ok "python3" "$(python3 --version 2>&1)"; else miss "python3" "not installed. Install Python 3.8 or newer from https://python.org"; fi

# Chinese font (needed for on-screen text in the HyperFrames edit)
font=""
if command -v fc-list >/dev/null 2>&1; then font="$(fc-list :lang=zh family 2>/dev/null | head -1)"; fi
if [ -z "$font" ] && [ "$osn" = mac ] && ls /System/Library/Fonts/PingFang.ttc >/dev/null 2>&1; then font="PingFang SC (system)"; fi
if [ -n "$font" ]; then ok "chinese font" "$font"
else miss "chinese font" "none found. Install Noto Sans SC (https://fonts.google.com/noto/specimen/Noto+Sans+SC), then run this check again"; fi

# Chrome (for bsk)
chrome=""
case $osn in
  mac) [ -d "/Applications/Google Chrome.app" ] && chrome="Google Chrome.app";;
  linux) command -v google-chrome >/dev/null 2>&1 && chrome="google-chrome";;
  windows) ls "/c/Program Files/Google/Chrome/Application/chrome.exe" >/dev/null 2>&1 && chrome="chrome.exe";;
esac
if [ -n "$chrome" ]; then ok "chrome" "$chrome"; else warn "chrome" "not found at the usual place. Install Google Chrome (or Edge). It must be the browser signed in to XHS"; fi

# bsk
if [ -n "$BSK_BIN" ]; then
  ok "bsk" "$("$BSK_BIN" --version 2>&1 | head -1) ($BSK_BIN)"
  out="$("$BSK_BIN" doctor 2>&1)"
  echo "$out" | grep -q "^FAIL.*extension connected" && miss "bsk extension" "no browser connected. Install the BrowserSkill extension in Chrome (SETUP.md step 5) and keep Chrome open"
  echo "$out" | grep -q "^FAIL.*extension connected" || ok "bsk extension" "browser connected"
  echo "$out" | grep -E "^FAIL" | grep -v "extension connected" | while read -r l; do echo "MISSING  bsk doctor            $l"; done
  echo "$out" | grep -E "^FAIL" | grep -vq "extension connected" && bad=1
  if echo "$out" | grep "agent skill matches" | grep -q "no agent skill installed"; then
    if [ "${XHS_SKIP_BSK_SKILL:-}" = 1 ]; then warn "bsk agent skill" "not installed (skipped: XHS_SKIP_BSK_SKILL=1, test runs only)"
    else miss "bsk agent skill" "not installed in Codex. Run: bsk install-skill --harness Codex -y   (required, SETUP.md B5; test runs may set XHS_SKIP_BSK_SKILL=1)"; fi
  else echo "$out" | grep -q "agent skill matches" && ok "bsk agent skill" "installed"; fi
else
  miss "bsk" "not installed. macOS/Linux: curl -fsSL https://raw.githubusercontent.com/Tencent/BrowserSkill/main/install.sh | sh   Windows: irm https://raw.githubusercontent.com/Tencent/BrowserSkill/main/install.ps1 | iex"
fi

# HyperFrames (video editing; separate skill, installed by the client)
hf="$("$here/check-hyperframes.sh" 2>&1)" ; hfrc=$?
printf "%s\n" "$hf"
[ "$hfrc" != 0 ] && bad=1

# Workspace + profile
if [ -z "${XHS_HOME:-}" ]; then
  warn "workspace" "no storage folder chosen yet: the first run (SETUP.md stage A0) asks the client and runs workspace.sh set"
else
  [ -d "$XHS_HOME" ] && ok "workspace" "$XHS_HOME" || miss "workspace" "saved folder $XHS_HOME is missing (moved or drive not connected). Reconnect it or run workspace.sh set NEWFOLDER"
  if [ -f "$XHS_PROFILE" ]; then
    python3 "$here/profile-check.py" "$XHS_PROFILE" --brief && ok "profile" "$XHS_PROFILE complete" || warn "profile" "incomplete; the first-run interview continues from there"
  else warn "profile" "no profile.json yet: the first-run interview (SETUP.md) creates it"; fi
fi

echo
if [ "$bad" = 0 ]; then echo "RESULT: all required parts present."; else echo "RESULT: something is MISSING. Fix the lines above, then run doctor.sh again."; fi
exit $bad

#!/usr/bin/env bash
# Shared settings. Source this file; do not run it.
# XHS_HOME = the client's workspace (profile, logs, jobs). There is NO fixed default folder.
# Order: the XHS_HOME environment variable, then the path saved by `workspace.sh set`
# (file: ${XDG_CONFIG_HOME:-~/.config}/xhs-studio/workspace). If neither exists the script stops
# with exit 12 and tells the agent to run the first-run workspace step (SETUP.md stage A0).
# A script that must work without a workspace (doctor, workspace.sh) sets XHS_ENV_OPTIONAL=1 first.
_xhs_ptr="${XDG_CONFIG_HOME:-$HOME/.config}/xhs-studio/workspace"
if [ -z "${XHS_HOME:-}" ] && [ -s "$_xhs_ptr" ]; then XHS_HOME="$(head -1 "$_xhs_ptr")"; fi
if [ -z "${XHS_HOME:-}" ]; then
  if [ "${XHS_ENV_OPTIONAL:-0}" != 1 ]; then
    echo "NO WORKSPACE: the client has not chosen a storage folder yet. Run SETUP.md stage A0 (bash scripts/workspace.sh set FOLDER)." >&2
    exit 12
  fi
else
  export XHS_HOME
  export XHS_STATE="$XHS_HOME/state"
  export XHS_LOG="$XHS_HOME/log"
  export XHS_PROFILE="$XHS_HOME/profile.json"
  mkdir -p "$XHS_STATE" "$XHS_LOG" 2>/dev/null || true
fi

# bsk (browser-skill) binary: BSK_BIN, then PATH, then the default install dir.
if [ -n "${BSK_BIN:-}" ]; then :
elif command -v bsk >/dev/null 2>&1; then BSK_BIN="$(command -v bsk)"
elif [ -x "${BSK_INSTALL_DIR:-$HOME/.local/bin}/bsk" ]; then BSK_BIN="${BSK_INSTALL_DIR:-$HOME/.local/bin}/bsk"
else BSK_BIN=""; fi
export BSK_BIN

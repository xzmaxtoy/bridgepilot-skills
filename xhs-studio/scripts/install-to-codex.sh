#!/usr/bin/env bash
# Install this skill folder into the chosen agent skills folder (legacy filename) (copy, no network).
# Usage: install-to-codex.sh [--dest DIR] [--force]
#   default DEST: ~/.agents/skills   (the folder `bsk install-skill --harness Codex` also uses;
#   older Codex builds read ~/.codex/skills: pass --dest ~/.codex/skills if yours does)
# Safe: never touches the client workspace (the folder the client chose) or profile.json.
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
dest="$HOME/.agents/skills"; force=0
while [ $# -gt 0 ]; do case "$1" in --dest) dest="$2"; shift 2;; --force) force=1; shift;; *) echo "usage: install-to-codex.sh [--dest DIR] [--force]"; exit 1;; esac; done
target="$dest/xhs-studio"
mkdir -p "$dest"
if [ -e "$target" ] && [ "$force" = 0 ]; then
  old="$(grep -m1 '^[[:space:]]*version:' "$target/SKILL.md" 2>/dev/null || true)"
  new="$(grep -m1 '^[[:space:]]*version:' "$here/SKILL.md")"
  echo "xhs-studio already installed here ($old). New package: $new."
  echo "Re-run with --force to update. Client data (profile, logs, jobs) lives in the workspace folder (the folder the client chose; path saved in ~/.config/xhs-studio/workspace) and is never touched by this installer."
  exit 1
fi
mkdir -p "$target"
for item in SKILL.md README.md SETUP.md CHANGELOG.md LICENSES.md DEPENDENCIES.md references scripts brand evals assets; do
  [ -e "$here/$item" ] && { mkdir -p "$target"; cp -R "$here/$item" "$target/"; }
done
chmod +x "$target/scripts/"*.sh "$target/scripts/"*.py 2>/dev/null || true
echo "Installed xhs-studio to $target"
echo "There is no fixed data folder: the first run asks the client where to store everything and saves that path. Client data is never inside the skill folder."
echo "Next: load this folder in your agent app and say:  use xhs-studio, run the first-time setup"

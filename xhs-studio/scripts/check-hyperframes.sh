#!/usr/bin/env bash
# Is HyperFrames (video editing) ready? The skill does not bundle it: the client installs it.
# Exit 0 = ready, 1 = something missing (the fix is printed). Used by doctor.sh.
# HyperFrames: github.com/heygen-com/hyperframes, Apache 2.0, needs Node 22+ and ffmpeg.
set -uo pipefail
bad=0
found=""
for d in "$HOME/.agents/skills" "$HOME/.codex/skills" "$HOME/.claude/skills"; do
  [ -f "$d/hyperframes/SKILL.md" ] && { found="$d/hyperframes"; break; }
done
if [ -n "$found" ]; then echo "OK       hyperframes skill      $found"
else
  echo "MISSING  hyperframes skill      not installed. Run:  npx hyperframes skills update   (installs the core skills: hyperframes, hyperframes-cli, hyperframes-registry, media-use)"
  echo "                                or:  npx skills add heygen-com/hyperframes --skill hyperframes --skill hyperframes-cli --skill media-use   (needs Node 22+). Then reload the current agent app if required."
  bad=1
fi
if command -v node >/dev/null 2>&1; then
  major="$(node -p 'process.versions.node.split(".")[0]')"
  [ "$major" -ge 22 ] && echo "OK       node (hyperframes)     v$major" || { echo "MISSING  node (hyperframes)     v$major is too old; HyperFrames needs Node 22 or newer (https://nodejs.org)"; bad=1; }
else echo "MISSING  node (hyperframes)     not installed; HyperFrames needs Node 22 or newer (https://nodejs.org)"; bad=1; fi
command -v ffmpeg >/dev/null 2>&1 && echo "OK       ffmpeg (hyperframes)   present" || { echo "MISSING  ffmpeg (hyperframes)   not installed (macOS: brew install ffmpeg)"; bad=1; }
if command -v hyperframes >/dev/null 2>&1; then echo "OK       hyperframes cli        $(hyperframes --version 2>&1 | head -1)"
else echo "WARN     hyperframes cli        not installed globally. That is fine: it runs on demand as  npx hyperframes ...  (first run downloads it; needs internet)"; fi
exit $bad

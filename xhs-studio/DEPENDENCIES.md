# Dependencies

`bash scripts/doctor.sh` checks all of these and prints a fix for each. Guided install: `SETUP.md` stage B. Updated for v0.2.0 (2026-11-08). macOS (Apple silicon).

| # | Dependency | Why | Check | Install |
|---|---|---|---|---|
| 1 | Codex (ChatGPT subscription) on the client's computer | Runs the skill | client opens Codex | the client's own account and plan |
| 2 | Node.js **22 or newer** + npm | Runs HyperFrames | `node -v` (major 22+), `npm -v` | https://nodejs.org ; macOS `brew install node@22` |
| 3 | ffmpeg + ffprobe | Cuts raw phone video; HyperFrames encodes with it | `ffmpeg -version`, `ffprobe -version` | macOS `brew install ffmpeg`; Windows `winget install Gyan.FFmpeg`; Linux `sudo apt install ffmpeg` |
| 4 | Python 3.8+ | cutdown, lint, profile check, upload server | `python3 --version` | https://python.org (macOS has it with Xcode tools) |
| 5 | A Chinese font (Noto Sans SC, PingFang SC or Microsoft YaHei) | On-screen text and cover | `fc-list :lang=zh` (macOS: PingFang is built in) | https://fonts.google.com/noto/specimen/Noto+Sans+SC |
| 6 | HyperFrames + its agent skill (**/hyperframes**) | Does the video edit and Chinese text; this skill hands it a brief | `bash scripts/check-hyperframes.sh` (skill folder `~/.agents/skills/hyperframes/SKILL.md` present) | `npx hyperframes skills update` (core skills) or `npx skills add heygen-com/hyperframes --skill hyperframes --skill hyperframes-cli --skill media-use`; then restart Codex. Source: github.com/heygen-com/hyperframes (Apache 2.0). The CLI itself runs on demand as `npx hyperframes` |
| 7 | A folder for the client's workspace | Profile, logs, jobs, footage | `bash scripts/workspace.sh status` | the first run asks the client and runs `workspace.sh set FOLDER` (a ChatGPT project folder or any folder) |
| 8 | Google Chrome (or Edge) signed in to XHS | The browser bsk drives | doctor shows chrome | https://www.google.com/chrome |
| 9 | bsk CLI | Drives the client's Chrome | `bsk --version` | macOS/Linux `curl -fsSL https://raw.githubusercontent.com/Tencent/BrowserSkill/main/install.sh \| sh`; Windows `irm https://raw.githubusercontent.com/Tencent/BrowserSkill/main/install.ps1 \| iex` |
| 10 | BrowserSkill Chrome extension (local connection on) | Connects bsk to Chrome | `bsk doctor` line "extension connected" is ok | https://chromewebstore.google.com/detail/hhcmgoofomhgciiibhipgmgkgnoenaoi |
| 11 | bsk skill in Codex | Official browser-skill instructions for Codex | `bsk doctor` line "agent skill matches" is ok | `bsk install-skill --harness Codex -y` |
| 12 | xhs-studio in Codex's skills folder | This skill | `ls ~/.agents/skills/xhs-studio/SKILL.md` | `bash scripts/install-to-codex.sh` (default `~/.agents/skills`; use `--dest ~/.codex/skills` on older Codex) |
| 13 | The client's XHS creator-center sign-in | Publish, inbox, insights | `bsk-check-page.sh` exit 0 on creator.xiaohongshu.com | the client signs in (credentials, 2FA and captchas are theirs) |

Helper scripts that need no extra install: `unpack-footage.py` (Python only), `prep-stills.sh` (macOS `sips`; elsewhere `heif-convert` from libheif, or ImageMagick `magick`), `shrink-to-limit.sh` (ffmpeg).

Disk: HyperFrames downloads its own render browser on first use (a few hundred MB), plus space for footage and renders. Network: needed only for installs and for XHS itself.

Windows note: the helper scripts are bash. Use Git Bash or WSL. Not tested on Windows; the ffmpeg, Node and bsk parts have Windows installers, the bash wrappers are unverified there.

No keys, accounts or paid services are needed beyond the client's own ChatGPT/Codex plan. Licence notes: `LICENSES.md`.

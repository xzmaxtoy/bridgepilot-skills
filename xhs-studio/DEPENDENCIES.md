# Dependencies

`bash scripts/doctor.sh` checks all of these and prints a fix for each. Guided install: `SETUP.md` stage B. Updated for v0.4.1 (2026-11-08). macOS (Apple silicon).

| # | Dependency | Why | Check | Install |
|---|---|---|---|---|
| 1 | Agent app with authorized local tools | Runs the skill | verify skill loading, file/command access and BrowserSkill in the actual host | client's chosen supported app; no named subscription prerequisite |
| 2 | Node.js **22 or newer** + npm | Runs HyperFrames | `node -v` (major 22+), `npm -v` | https://nodejs.org ; macOS `brew install node@22` |
| 3 | ffmpeg + ffprobe | Cuts raw phone video; HyperFrames encodes with it | `ffmpeg -version`, `ffprobe -version` | macOS `brew install ffmpeg`; Windows `winget install Gyan.FFmpeg`; Linux `sudo apt install ffmpeg` |
| 4 | Python 3.8+ | cutdown, lint, profile check, upload server | `python3 --version` | https://python.org (macOS has it with Xcode tools) |
| 5 | A Chinese font (Noto Sans SC, PingFang SC or Microsoft YaHei) | On-screen text and cover | `fc-list :lang=zh` (macOS: PingFang is built in) | https://fonts.google.com/noto/specimen/Noto+Sans+SC |
| 6 | HyperFrames + its agent skill (**/hyperframes**) | Does the video edit and Chinese text; this skill hands it a brief | `bash scripts/check-hyperframes.sh` (skill folder `~/.agents/skills/hyperframes/SKILL.md` present) | `npx hyperframes skills update` (core skills) or `npx skills add heygen-com/hyperframes --skill hyperframes --skill hyperframes-cli --skill media-use`; then reload the current host if required. Source: github.com/heygen-com/hyperframes (Apache 2.0). The CLI itself runs on demand as `npx hyperframes` |
| 7 | A folder for the client's workspace | Profile, logs, jobs, footage | `bash scripts/workspace.sh status` | the first run asks the client and runs `workspace.sh set FOLDER` (any accessible client-chosen folder) |
| 8 | Google Chrome (or Edge) signed in to XHS | The browser bsk drives | doctor shows chrome | https://www.google.com/chrome |
| 9 | bsk CLI | Drives the client's Chrome | `bsk --version` | macOS/Linux `curl -fsSL https://raw.githubusercontent.com/Tencent/BrowserSkill/main/install.sh \| sh`; Windows `irm https://raw.githubusercontent.com/Tencent/BrowserSkill/main/install.ps1 \| iex` |
| 10 | BrowserSkill Chrome extension (local connection on) | Connects bsk to Chrome | `bsk doctor` line "extension connected" is ok | https://chromewebstore.google.com/detail/hhcmgoofomhgciiibhipgmgkgnoenaoi |
| 11 | Official browser-skill in the current agent | Browser safety and host-specific tool interface | verify the current host loaded the instructions | inspect `bsk install-skill --help` for supported harnesses; use the current host, not a hard-coded Codex option |
| 12 | xhs-studio loaded by the current agent | This skill | confirm the host can read its SKILL.md and supporting assets | host-supported installation; legacy installer accepts `--dest DIR` and defaults to `~/.agents/skills` |
| 13 | The client's XHS creator-center sign-in | Publish, inbox, insights | `bsk-check-page.sh` exit 0 on creator.xiaohongshu.com | the client signs in (credentials, 2FA and captchas are theirs) |

| 14 | HeyGen helper (only for catalog music) | Retrieves free catalog tracks via HyperFrames/media-use | `bash scripts/check-music.sh`; `heygen --version` | Follow https://developers.heygen.com/cli; respect existing install authorization. Then `npx hyperframes auth status`, client-completed `npx hyperframes auth login` if needed, recheck and prove track retrieval. |

Helper scripts that need no extra install: `unpack-footage.py` (Python only), `prep-stills.sh` (macOS `sips`; elsewhere `heif-convert` from libheif, or ImageMagick `magick`), `shrink-to-limit.sh` (ffmpeg).

Disk: HyperFrames downloads its own render browser on first use (a few hundred MB), plus space for footage and renders. Network: needed only for installs and for XHS itself.

Windows note: the helper scripts are bash. Use Git Bash or WSL. Not tested on Windows; the ffmpeg, Node and bsk parts have Windows installers, the bash wrappers are unverified there.

Local editing needs no additional service account. The optional free music catalog needs the HeyGen helper and HyperFrames sign-in; generated music is a separate credits-based choice. Licence notes: `LICENSES.md`.

Optional scheduling requires a verified host scheduler with access to the same local workspace/browser. A reminder alone is not unattended execution. See `references/scheduling.md`; no schedule is created during installation.

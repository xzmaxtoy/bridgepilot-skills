# Licences, and what a reseller must do

bsk checked 2026-10-14, HyperFrames checked 2026-11-08, both from the vendors' own pages. This is a working summary, not legal advice. Re-check before each new client.

xhs-studio itself contains no bsk code and no HyperFrames code. The client installs both from their official sources on their own computer (the bsk installer; `npx hyperframes skills update`).

## bsk (BrowserSkill CLI + Chrome extension)
- Source: github.com/Tencent/BrowserSkill. Licence: **MIT**. Extension on the Chrome Web Store (free).
- The project states it runs no mandatory cloud service and collects no product telemetry. Page results go to the local daemon and to the agent that asked.
- Reseller duty: none beyond MIT's one rule. If you ever **redistribute** bsk (bundle its code or binary in your own package), keep its copyright and licence notice. xhs-studio does not bundle it: the client installs it from upstream. Keep it that way.
- Tell the client plainly that bsk drives their own logged-in Chrome through an extension they install.

## HyperFrames (video editing and Chinese text; separate skill /hyperframes)
- Source: github.com/heygen-com/hyperframes (HeyGen). Licence: **Apache 2.0** (the LICENSE file is the standard Apache 2.0 text; npm package `hyperframes` 0.9.22 also says Apache-2.0). The README states: "no per-render fees or commercial-use thresholds." Needs Node 22+ and FFmpeg.
- Reseller duty: none beyond Apache 2.0's normal terms. xhs-studio does not bundle or copy HyperFrames code, so no notice must be shipped. If you ever redistribute HyperFrames files, keep its LICENSE and NOTICE and mark changes.
- **Replaces Remotion.** Remotion needed a paid Company Licence above 3 people (seller and client counted together) and had an unsettled "Automators" tier; none of that applies to HyperFrames. v0.2.0 ships no Remotion code.
- **Telemetry:** the HyperFrames CLI sends anonymous usage telemetry by default (from its own docs: opt out with the environment variable `HYPERFRAMES_NO_TELEMETRY=1` or `DO_NOT_TRACK=1`; it is anonymous until the user signs in to a HyperFrames account). Tell the client; record their choice. xhs-studio never signs in for them.
- Not verified: whether the HyperFrames skill terms or its optional paid services (auth, billing, templates, Figma, vision keys) add limits. The skill needs none of them.
- Check again before each new client.

## Other components (installed by the client, not shipped here)
| Component | Licence note |
|---|---|
| Headless Chrome used by HyperFrames to render (downloaded by it on first use) | Chromium BSD-style plus bundled third-party licences, text inside the download |
| ffmpeg / ffprobe | LGPL or GPL depending on the build; installed from the client's package manager, not redistributed |
| Node.js | MIT |
| Noto Sans SC | SIL Open Font Licence; installed by the client, not shipped here |

## What is NOT covered
Xiaohongshu's own terms of service and its rules on automation are the client's risk, not a software licence. The skill's three switches default to OFF for that reason.

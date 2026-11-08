# xhs-studio (v0.2.0)

A Codex skill that runs one small business's Xiaohongshu (RedNote) account from the client's own computer: raw phone footage -> short vertical post (edit and Chinese text by the separate /hyperframes skill) -> caption draft -> publish form -> comments, DMs and numbers. Real footage only. Chinese is always a draft the client approves. Three automation switches (auto-publish, auto-reply comments, auto-reply DMs), all OFF by default. The skill always stops before 发布 until the client approves.

## For the client's agent: download and install
1. Download the package: `https://github.com/xzmaxtoy/bridgepilot-skills` (green **Code** button > **Download ZIP**, or `git clone https://github.com/xzmaxtoy/bridgepilot-skills.git`). The skill folder is `xhs-studio/`.
2. Unzip it. In a terminal, from inside the `xhs-studio` folder:
```
bash scripts/install-to-codex.sh            # copies to ~/.agents/skills/xhs-studio
# older Codex builds:  bash scripts/install-to-codex.sh --dest ~/.codex/skills
# to update later:     bash scripts/install-to-codex.sh --force
```
3. Restart Codex, open it and say: **use xhs-studio, run the first-time setup**.

The guided first run (`SETUP.md`) does, in order: asks where to store everything (a ChatGPT project folder or any folder) and guides the client to create the ChatGPT project (Work mode), asks the interview questions, installs and checks every dependency (including the separate HyperFrames skill: `npx hyperframes skills update`), and ends with a dry run that stops before anything is published.

## What is in the folder
`SKILL.md` (entry) - `SETUP.md` (first run) - `DEPENDENCIES.md` - `LICENSES.md` - `CHANGELOG.md` - `references/` - `scripts/` - `brand/profile.template.json` (blank profile) - `evals/`.
No brand, client data, footage or Remotion code is shipped.

## Workspace folder
There is no fixed folder. The first run asks the client where to store everything and saves the path (`~/.config/xhs-studio/workspace`). Profile, logs, jobs and footage live in `<chosen folder>/xhs-studio/`, never in the skill folder. Every script reads the saved path.

## Self-test (no XHS account touched)
`bash scripts/self-test.sh` runs the offline checks: copy lint, profile check, switches, kill switch, workspace folder, page classifier, cutdown on synthetic clips, final-check gate.

# xhs-studio (v0.5.0)

An agent skill that runs one small business's Xiaohongshu (RedNote) account from the client's own computer: raw phone footage -> storyline and storyboard -> vertical post (edit and Chinese text by the separate /hyperframes skill) -> caption draft -> publish form -> comments, DMs and numbers. Real footage only. Chinese is always a draft the client approves. Three automation switches (auto-publish, auto-reply comments, auto-reply DMs), all OFF by default. The skill always stops before 发布 until the client approves.

## For the client's agent: download and install
1. Download the package: `https://github.com/xzmaxtoy/bridgepilot-skills` (green **Code** button > **Download ZIP**, or `git clone https://github.com/xzmaxtoy/bridgepilot-skills.git`). The skill folder is `xhs-studio/`.
2. Unzip it. In a terminal, from inside the `xhs-studio` folder:
```
bash scripts/install-to-codex.sh            # copies to ~/.agents/skills/xhs-studio
# Codex-specific alternate destination:  bash scripts/install-to-codex.sh --dest ~/.codex/skills
# to update later:     bash scripts/install-to-codex.sh --force
```
3. Install/load the folder using your agent app's supported skill mechanism, then say: **use xhs-studio, run the first-time setup**.

Setup is progressive, not a blocking wizard. The agent infers Setup, Plan, Create, Publish, Inbox or Insights from the request and checks only that action's prerequisites. It prefills sourced facts, asks small recommended question groups, and refines preferences through the first storyboard/preview. Missing publishing setup cannot block offline plans or saved-report analysis; actual permissions and approvals still apply at the relevant action.

The installer keeps its legacy filename but accepts `--dest <your-host-skill-directory>`. Confirm that directory and skill support in your actual app; do not assume every agent reads `~/.agents/skills`. A host must expose authorized local commands/files and BrowserSkill, or offer a verified equivalent interface. Compatibility with every app has not been tested.

## What is in the folder
`SKILL.md` (entry) - `SETUP.md` (first run) - `DEPENDENCIES.md` - `LICENSES.md` - `CHANGELOG.md` - `references/` - `scripts/` - `brand/profile.template.json` (blank profile) - `evals/`.
No brand, client data, footage or Remotion code is shipped.

## Workspace folder
There is no fixed folder. The first run asks the client where to store everything and saves the path (`~/.config/xhs-studio/workspace`). Profile, logs, jobs and footage live in `<chosen folder>/xhs-studio/`, never in the skill folder. Every script reads the saved path.

## Self-test (no XHS account touched)
`bash scripts/self-test.sh` runs the offline checks: copy lint, profile check, switches, kill switch, workspace folder, page classifier, cutdown on synthetic clips, final-check gate.

## Weekly visual review
Download official Creator Center analytics before collecting missing UI context. Build an offline visual report with daily traffic, scoped per-post comparisons, local audience/keyword evidence, and a draft next experiment. Unknown inquiries and business outcomes stay unknown. See [insights](references/insights.md) and the [report contract](references/weekly-report.md). No account data ships in the template.

## Optional scheduling across agent apps
Scheduling is provided by the host, not by xhs-studio. Use its supported scheduler only after verifying it can run the agent with the local workspace and approved browser. Start with a one-shot preview-only draft check, keep action switches independent, and verify deletion when a test is discarded. If unattended execution is unavailable, use manual checks or a clearly labelled reminder. See [scheduling](references/scheduling.md).

## Durable files and repeat production
Final reports are saved under the chosen workspace's `reports/<account-key>/<period>/`; final video jobs under `jobs/<job>/`, unless the client chooses another destination. Host output folders are staging copies. The next video reads that account's report and previous experiment and records its evidence-led hypothesis in the job brief. Test-account reports never silently guide another business. See [production cycle](references/production-cycle.md).

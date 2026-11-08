# Repeat production: report to the next video

A production cycle is a content workflow, not permission to schedule or publish. Use the chosen client workspace as the durable source of truth; another agent app should be able to resume from files rather than needing this chat's memory.

Planning is an independent flow. Use a selected report to prepare a provisional brief even if publishing setup or full-profile milestones are incomplete. Ask only essentials needed for the next decision, keep missing footage/permissions explicit, and do not invoke browser or editing checks for an offline handoff.

## Before proposing the next post

1. Confirm the business/account for the new job. Read its profile, recent published-job log and latest completed report under `$XHS_HOME/reports/<account-key>/`. Prefer `latest-report.json` when present; verify the referenced report/data exist, their account matches, and their period and collection date are suitable. A missing pointer is not permission to use another account: discover that account's dated reports instead.
2. Read the report's normalized results, evidence limitations, local targeting audit, prior experiment and measured business outcomes, plus relevant recent reader-question summaries. Inspect the prior job brief so an already-tested change is not repeatedly proposed as new. Identify stale/missing data explicitly. Do not treat a test report (`latest-test-report.json`) or cross-business report as live production evidence unless the client explicitly chooses that test context.
3. Extract one or two defensible findings, with exact report/file and metric references. Compare compatible windows and sufficient samples. With thin data, frame a hypothesis to test, not a winning formula. Reach alone does not determine the next video.
4. Check real available footage and permissions. A report can change the hook, local keyword, structure or CTA, but cannot supply an absent finished result, invented service or customer story. Offer the applicable HyperFrames story choices and storyboard before editing.

## Make the handoff concrete

Write a short `next-video-brief.json` in the new job folder (or an equivalent section in the existing brief):

- account/business identity and relative path to the source report/data;
- report period, source scope, findings with supporting metrics, and unresolved limitations;
- target viewer/geography, one primary hypothesis and what to keep/change from the last post;
- draft hook/local keyword/CTA and required footage;
- primary outcome, how the owner will count it, observation windows and the next decision;
- plan/copy approval state and eventual published note ID, initially unknown.

Use an explicit next-decision rule appropriate to the sample: continue gathering evidence, repeat the test, or revise it based on local inquiries and content signals. Do not promise statistical certainty from one post. The client can override a report-led recommendation; record that choice instead of silently reverting it.

After plan and copy approval, proceed through normal video creation/review. Approval of the report or recurring plan never approves a new cut, caption or publishing action. Save final videos, covers, captions and briefs under `$XHS_HOME/jobs/<job>/` (or the client's explicitly selected destination); scratch previews may live in a host's working directory.

After publishing, record note ID and outcome windows (+24 h / +72 h / weekly). The next report evaluates the hypothesis and links back to that brief; the following video reads those results. Unknown business outcomes stay unknown. Do not automatically start jobs or create schedules merely because a report contains a next-post suggestion. For an explicitly requested cadence, use `scheduling.md` and verify that the host can run that specific workflow.

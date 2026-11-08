# Inbox checks across agent apps

This is a host-neutral workflow, not a ChatGPT dependency. Apply it in Codex, ChatGPT desktop, Claude Desktop or another agent **only after checking what that actual installation can do**. App names do not establish tool access, scheduling support, subscription eligibility or unattended execution. Do not claim a host is tested because it can display the skill.

## Capability check, before offering a schedule

Discover the current host's supported skills, local commands/files, BrowserSkill connection, persistent scheduler and notification channel. Verify:

- The execution environment can read this skill, the chosen client workspace and prior scan state, and run the installed BrowserSkill interface. An MCP-only or cloud-only host may not expose the local CLI; use its documented supported interface or report the missing capability. Never invent tool names.
- The scheduler really launches the agent with these tools and access. A reminder that asks the user to check messages is not an unattended inbox scan. A cloud job does not automatically inherit a desktop browser login or local files.
- The explicitly selected browser instance and account can be reused by a fresh scheduled session. Persist the approved binding in local client state; never ship an instance ID in the skill. A disconnected required profile is a blocker, not permission to switch.
- Whether the computer, app, browser extension and network must remain available; state verified requirements and what is untested. Do not promise cloud/always-on operation without evidence.

Prefer the host's native scheduling tools/UI and its documented discovery, update and deletion workflow. If unavailable, offer manual “check now” or a reminder as a clearly limited fallback. Configure an OS/external scheduler only when explicitly authorized and the chosen runner has been verified; do not silently install one or replace the user's agent app.

## Agree the job in one compact group

Reuse known preferences. Confirm or recommend cadence, timezone, read scope, draft-only vs separately authorized sending, notification destination and what merits notification. Recommend preview-only, draft-only and alerts for new actionable messages or blockers. The three XHS action switches and kill switch remain independent: creating a schedule never enables replies or publishing.

For a test, prefer one future occurrence with a clear end. Confirm the scheduler's resolved next run/timezone and bounded recurrence, not just that it accepted a rule. A schedule creation is not proof of execution. If the host cannot express a one-shot run, disclose that before creating a recurring substitute. After execution verify the run reached the intended account and produced evidence; only then mark that route tested.

## Portable job brief

Adapt this brief to the host's real tools rather than copying app-specific tool calls:

> At the agreed times and timezone, load xhs-studio and browser-skill from their installed locations. Read the client workspace and previous scan state. Bind each fresh browser session to the approved browser instance; verify the expected XHS account. Check a small batch of comment notifications and DM previews, and compare with the previous successful scan. Do not open unread DMs or mark conversations read unless explicitly authorized for this run. Label unknown sender/context; a last-message preview may be ours. Draft concise replies in the confirmed language and voice only for supported new cases. Send nothing in draft-only mode, and never type drafts into a live composer. Escalate price, booking, contact requests, complaints and abuse. Do not invent availability or business claims. Stop on login/CAPTCHA/platform warnings or loss of the required browser. Save minimal pseudonymous summaries, evidence state and draft IDs locally, not customer contact details or full histories. Close owned browser resources even on failure. Record run success, partial coverage or blocker and preserve the last successful baseline when the scan fails.

Put notification settings in the host's notification fields when provided. For ordinary monitoring stay quiet when nothing actionable changed; alert on new intent, escalation, failure or required user action. A one-shot test may explicitly request a completion result even with no change. Do not send notifications through a different external messaging service without authorization.

## State and lifecycle

Keep durable client state independent of the host chat: workspace path, browser/account binding, successful scan cursor or per-thread last-message metadata, scope/coverage, scheduler provider/job ID, timezone, next run and action mode. Existing `inbox-state.json` and daily logs can hold scan data; store scheduler metadata in `$XHS_HOME/log/patterns/inbox-schedule.json` or equivalent. Store no credentials. Partial historical scans are not new leads and should not replace a complete daily baseline silently.

Do not overlap checks against the same account. If an earlier owned run is active, skip the duplicate and log it. Do not steal another session. Keep each run small; inspect new context instead of repeatedly greeting readers or replying to our own last message.

“Discard/delete this test” means remove the corresponding scheduled job through the host's supported tool/UI and verify it no longer has a future run. “Pause” means disable it while retaining its configuration. Deleting a schedule does not necessarily cancel a run already executing: inspect and stop that owned run if needed. Do not delete client logs, drafts or other schedules, and do not archive the conversation. If removal fails, report it and disable the job when possible; never claim it is gone without evidence.

## Evidence status

One local manual BrowserSkill test read comments and two DM threads, confirmed incoming vs our last bubble, and prepared unsent drafts. Opening one unread thread marked it read. One host scheduler accepted a temporary one-occurrence inbox job; it was deleted before execution was verified. Thus manual read/draft was tested, scheduled browser execution and automatic sending were not. Revalidate on each agent app and environment.

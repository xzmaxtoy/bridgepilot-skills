# Ask Before You Advise

A small skill that makes your AI tool interview you before it gives business advice. It asks for your company document and brand document, asks one question at a time (each with a suggested answer), waits until you confirm the big picture, then gives direction, strategy and an action plan. It ends with what you decided, what changed, what is still uncertain, and suggested edits to your two documents.

It works with chat alone. It needs no other tools.

It goes with the BridgePilot post "How to get AI advice that fits your business: 4 steps".

## Install in Claude
1. In a terminal, run `claude plugin marketplace add xzmaxtoy/bridgepilot-skills`.
2. Then run `claude plugin install ask-before-you-advise@bridgepilot-skills`.
3. Start a chat with a question like "Should I start a newsletter?" The skill starts when you ask for advice on a decision.

## Update
Run `claude plugin marketplace update bridgepilot-skills`. The skill is installed from this repo, so you always get the current version.

## Other tools (no skills)
Open `ask-before-you-advise/PROMPT.md`, fill the [brackets], and paste it at the start of a chat.

## Files
- `ask-before-you-advise/SKILL.md`: the skill
- `ask-before-you-advise/PROMPT.md`: one-paste version
- `.claude-plugin/marketplace.json`: makes this repo installable as a Claude Code marketplace
- `tests/`: the simulated chats, plus `evals.json`, the seven cases used to score it
- `LICENSE`: MIT

## Tested
Checked with simulated chats only (one AI playing both sides): 7 rounds, 3 different owners in a row passed on the final text; one owner replied in Mandarin. The one-paste prompt was tested alone in 3 runs and is weaker than the skill.

Re-tested 5 Nov 2026, after publishing, by reading four owner conversations against the skill's own rules. It found real faults: the confirmation step asked two questions while another rule forbids a second question; a bare "ok" and "just tell me what to do" were each read as a yes; one run changed $45 to £45; one carried its own suggested answer forward as the owner's. All four are fixed, and the two scenarios that failed now pass on a re-run.

Not tested: upload into Claude Settings, or any other tool.

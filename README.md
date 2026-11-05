# Ask Before You Advise

A small skill that makes your AI tool interview you before it gives business advice. It asks for your company document and brand document, asks one question at a time (each with a suggested answer), waits until you confirm the big picture, then gives direction, strategy and an action plan. It ends with what you decided, what changed, what is still uncertain, and suggested edits to your two documents.

It works with chat alone. It needs no other tools.

It goes with the BridgePilot post "How to get AI advice that fits your business: 4 steps".

## Install in Claude
1. Download `ask-before-you-advise.zip`. Do not unzip it.
2. In Claude, open Settings > Capabilities > Skills.
3. Upload the zip.
4. Start a chat with a question like "Should I start a newsletter?" The skill starts when you ask for advice on a decision.

## Other tools (no skills)
Open `PROMPT.md`, fill the [brackets], and paste it at the start of a chat.

## Files
- `skill/ask-before-you-advise/SKILL.md`: the skill
- `PROMPT.md`: one-paste version
- `LICENSE`: MIT

## Tested
Checked with simulated chats only (one AI playing both sides): 7 rounds, 3 different owners in a row passed on the final text; one owner replied in Mandarin. The one-paste prompt was tested alone in 3 runs and is weaker than the skill. Not tested: upload into Claude Settings, or any other tool.

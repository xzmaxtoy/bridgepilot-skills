You are running a simulation to test a one-paste prompt. Read /Users/jessexu/bridgepilot-skills/ask-before-you-advise/PROMPT.md and the persona file PERSONA_PATH. Read nothing else.
Write a chat transcript between two roles and save it to OUT_PATH (markdown, "OWNER:" / "ADVISOR:").
- The owner starts by pasting the prompt from PROMPT.md with the [brackets] filled in from the persona (and, if the persona has documents, pastes them under it).
- ADVISOR: a chat-only AI with NO tools. Its ONLY instructions are the pasted prompt, nothing else (it has never seen any SKILL.md). It behaves exactly as that prompt tells it, no better and no worse. Write its turns the way a real model would.
- OWNER: play the persona exactly, quirks included. About 14-20 turns; end with the owner asking to wrap up; include the final summary.
Only write the transcript file. Final reply: "done".

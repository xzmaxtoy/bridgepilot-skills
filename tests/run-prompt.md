You are running a simulation to test a skill. Read /Users/jessexu/bridgepilot-skills/ask-before-you-advise/skill/ask-before-you-advise/SKILL.md and the persona file PERSONA_PATH. Read nothing else.
Write a chat transcript between two roles and save it to OUT_PATH (markdown, each turn labelled "OWNER:" or "ADVISOR:").
- ADVISOR: a chat-only AI with NO tools (no files, no web, no search). Its ONLY instructions are the SKILL.md text, as if it were loaded. It must behave exactly as that text tells it, no better and no worse. Write its turns the way a real model would; do not polish them to look compliant.
- OWNER: play the persona exactly as described, including the quirks. The owner does not know the skill. The owner opens with the persona's request and, if the persona has documents, pastes them when asked.
- Run about 14-20 turns total. Continue until the advisor has given advice and the owner says it wants to stop; the owner's last message asks the advisor to wrap up. Include the advisor's final summary.
Only write the transcript file. In your final reply say only "done".

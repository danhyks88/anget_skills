---
name: context-3-turn
description: Use only the most recent three conversation turns unless explicitly asked otherwise.
---

# Context 3 Turn

Always follow:
1. Use at most the latest three conversation turns in the current session for reasoning and responses.
2. Do not summarize or revive older history unless it is necessary for the current request.
3. Prioritize direct action and concise, focused responses.
4. If information is outside the latest three turns, use it only when the user explicitly requests it.
5. Do not automatically retrieve project history or past conversations.

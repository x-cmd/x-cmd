---
description: Display the current status of the conversation.
---

<!-- BEGIN Update and Display Conversation Status Prompt -->
Goal: Ensure the conversation stats file is updated first, then display the current conversation status to the user in a clear, concise, and user-friendly way.

Strict requirements:
- Always call \`update_stats\` **before performing any reasoning, status display, or task execution**, especially if this is a new conversation or a key change occurred.
- Only use observable information; never fabricate or guess.
- Display the updated status in a readable, user-friendly format.
- Do not include extra commentary or instructions beyond the updated status display.
- Do not skip or delay the stats update. If \`update_stats\` fails, report the failure concisely and proceed without fabricating stats.

Rules for stats handling:
- The first action in any new conversation or session must be \`update_stats\` to create the initial stats file.
- Consult the stats file before making decisions or performing tasks.
- Update stats whenever the topic, plan, environment, or task progress changes.
- Updates must be accurate, minimal, and based on observed or confirmed information only.

Output:
- Call \`update_stats\` with the full YAML content reflecting current conversation context, environment, and tasks.
- Then present a clear, concise, user-friendly summary of the updated conversation status.

<!-- END Update and Display Conversation Status Prompt -->
---
%{ARGUMENTS}%

---
description: Emergency stop - halt all running agents immediately (usage: /halt [optional reason])
---

file:.claude/emergency-stop.md

CREATE HALT SIGNAL:

1. Create .claude/halt.lock file with this content:
   {
     "halted_at": "<current ISO timestamp>",
     "reason": "$ARGUMENTS",
     "halted_by": "user"
   }

2. Inform the user:
   "Emergency halt signal activated. All running agents will stop at their next checkpoint and suspend their work.

   Reason: $ARGUMENTS

   To resume normal operations, run: /resume"

Do NOT read files, do NOT analyze code, ONLY create the halt.lock file and inform the user.

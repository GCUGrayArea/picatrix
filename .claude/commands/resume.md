---
description: Resume normal operations after emergency halt
---

file:.claude/rules/emergency-stop.md

REMOVE HALT SIGNAL:

1. Check if .claude/halt.lock exists
   - If it doesn't exist: inform user "No active halt signal. Agents are already able to run."
   - If it exists: delete it

2. Inform the user:
   "Halt signal removed. Normal operations resumed.

   You can now start agents with /work. Any Suspended PRs from the halt can be resumed."

Do NOT read files, do NOT analyze code, ONLY remove the halt.lock file and inform the user.

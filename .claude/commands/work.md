---
description: Start working on the next available PR following parallel agent coordination rules
---

file:.claude/agent-defaults.md
file:.claude/agent-identity.md

You are starting a new work session.

1. First, claim an agent identity:
   - Read .claude/agent-identity.lock to see available identities
   - Take the first Available identity (White, Orange, Blonde, Pink, Blue, or Brown)
   - Update the lock file to mark it as In Use
   - Commit the identity claim immediately

2. Then, review docs/prd.md and docs/task-list.md, select the next appropriate PR according to the priority rules, and begin work.

3. Remember: When you complete or suspend your PR, release your identity in agent-identity.lock and commit that change.

Follow commit-policy.md - only auto-commit coordination files (task-list.md, prd.md, agent-identity.lock).

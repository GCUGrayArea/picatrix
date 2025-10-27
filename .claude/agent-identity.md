# Agent Identity System

All agents working on implementation PRs must claim a unique identity before starting work. This ensures clear attribution in commits and prevents confusion about who's doing what.

## Available Identities

Agents use **Reservoir Dogs color names**:
- White
- Orange
- Blonde
- Pink
- Blue
- Brown

**Maximum 6 agents working simultaneously.**

## Special Identities

**QC** - The Quality Control agent uses this fixed identity and does not participate in the lock system.

## Identity Lock File

Agent identities are tracked in `.claude/agent-identity.lock`. This file shows which identities are Available, In Use, or Timed Out.

## Claiming an Identity

**When you start work (via /work command):**

1. **Read agent-identity.lock** to see available identities
2. **Take the first Available identity** in the list
3. **Update the lock file:**
   ```markdown
   | White | In Use | 2025-10-27 14:30 | PR-005 |
   ```
4. **Commit immediately:**
   ```
   [White] Claimed identity for PR-005
   ```
5. **Use this identity** in all subsequent commits for coordination documents

## Using Your Identity

Once claimed, use your identity in all coordination document commits:

```bash
# Good examples
[White] PR-005: New → Planning [AuthService.ts, UserModel.ts]
[Orange] PR-008: Planning → In Progress [PaymentGateway.ts]
[Pink] PR-012: In Progress → Complete [Dashboard.tsx]
```

## Releasing an Identity

**When you complete or suspend your PR:**

1. **Update agent-identity.lock** to mark your identity as Available:
   ```markdown
   | White | Available | - | - |
   ```
2. **Commit immediately:**
   ```
   [White] Released identity after completing PR-005
   ```

**This allows other agents to use that identity.**

## Identity Timeout

If an identity has been "In Use" but has no commits in the last 12 hours, it may be reclaimed:

1. Check git log for that identity:
   ```bash
   git log --since="12 hours ago" --all-match --grep="\[White\]" -- docs/task-list.md
   ```

2. If no commits found:
   - Update lock file: status "Timed Out"
   - Commit: `[Orange] Marked White as timed out (no activity in 12+ hours)`
   - Then claim it yourself: status "In Use"
   - Commit: `[Orange] Reclaimed White identity for PR-010`

## QC Agent Exception

The **QC agent always uses the identity "QC"** and does not:
- Check agent-identity-lock.md
- Claim or release identities
- Interact with the lock system at all

QC commits look like:
```
[QC] PR-005: Complete → Broken [test failures in AuthService]
```

## Why This System?

- **Max 6 simultaneous agents** - Prevents chaos, keeps coordination manageable
- **Memorable names** - Easier to track than Agent-1, Agent-2, Agent-3
- **Clear ownership** - Git log shows exactly who did what
- **Automatic cleanup** - 12-hour timeout prevents abandoned identities from blocking others
- **Self-coordinating** - No centralized identity server needed, just a tracked markdown file

## Edge Cases

**What if all 6 identities are in use?**
- Wait for one to become Available or Timed Out
- Consider if some In Use identities have timed out (check git log)
- User may need to reduce number of parallel agents

**What if I need to pause work mid-PR?**
- Mark PR as Suspended (keeps your files locked)
- Release your identity (allows another agent to start different work)
- When resuming, claim any Available identity (doesn't have to be the same one)

**What if I'm only doing read-only analysis?**
- If you're not claiming any PRs (just reviewing, analyzing, answering questions), you don't need an identity
- Only claim identity when you're about to mark a PR as Planning or In Progress

**What if the lock file doesn't exist yet?**
- The template includes a default agent-identity.lock with all identities Available
- Planning agent should not need to create it
- If somehow missing, copy the format from .claude/agent-identity.md header

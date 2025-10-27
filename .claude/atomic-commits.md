# Atomic Commits for Coordination Documents

docs/prd.md, docs/task-list.md, and .claude/agent-identity.lock are high-traffic coordination files critical to running agents in parallel. Multiple agents read these files to determine what work is available, what files are locked, and which identities are in use.

## Rule

**Always commit every change to these coordination files immediately after making it:**
- docs/prd.md
- docs/task-list.md
- .claude/agent-identity.lock

Every status change, file list update, identity claim/release, or planning note must be its own atomic commit with a clear explanation.

## Commit Message Format

Use this pattern:
```
[Agent Name] PR-XXX: <old status> → <new status> [affected files]

Brief explanation of why this change was made.
```

## Examples

**Task list status changes:**
```
[White] PR-005: Planning → Blocked-Ready [AuthService.ts, UserModel.ts]

Completed planning but PR-007 is already working on AuthService.ts.
Will resume when PR-007 completes.
```

```
[Orange] PR-010: In Progress → Complete [PaymentGateway.ts, StripeAdapter.ts]

Implemented Stripe integration with error handling and retries.
All tests passing, coverage 94%.
```

```
[QC] PR-008: Complete → Broken [AuthService.ts]

Automated tests failed: token refresh returns 401 instead of 200.
Likely broken by PR-010's auth middleware changes.
```

**Identity claims/releases:**
```
[White] Claimed identity for PR-005
```

```
[Orange] Released identity after completing PR-010
```

```
[Pink] Reclaimed Blue identity (timed out - no activity in 12+ hours)
```

**Bad examples:**
```
[White] Updated task list

(No PR number, no status transition, no explanation)
```

```
Updated task list for PR-005

(No agent identity in brackets)
```

## Why This Matters

- **Prevents race conditions:** Other agents see your claim immediately
- **Enables conflict detection:** Git will surface if two agents claim the same PR
- **Creates audit trail:** Every decision is logged with reasoning
- **Supports rollback:** Can revert any state change cleanly
- **Allows monitoring:** You can watch `git log task-list.md` to see all agent activity

## When to Commit

Commit immediately after:
- Changing any PR status (New → Planning, Planning → Blocked-Ready, etc.)
- Adding file lists to a PR
- Adding planning notes or analysis
- Marking a PR as Broken with failure details
- Adding QC notes or coverage information
- Claiming an agent identity in agent-identity.lock
- Releasing an agent identity in agent-identity.lock
- Reclaiming a timed-out identity in agent-identity.lock

Do not batch multiple status changes into one commit. Each state transition is a separate atomic operation.
```

## Why This Works

**Separation of concerns:**
- `docs/agent_defaults.md` = workflow and coordination logic
- `docs/atomic_commits.md` = git hygiene for coordination documents
- `docs/qc-agent.md` = quality assurance procedures

**Enforceable:**
- Agents can be explicitly prompted to follow this
- Hooks can validate commit messages match the pattern
- You can audit compliance with `git log --oneline task-list.md`

**Scalable:**
- If you later add more coordination documents, just update the list in this rule
- The principle (atomic commits for high-traffic coordination files) remains constant

**Self-documenting:**
The commit log becomes a complete timeline of the project:
```
[QC] PR-008: Complete → Broken [AuthService.ts]
[Orange] PR-010: In Progress → Complete [PaymentGateway.ts, StripeAdapter.ts]
[Orange] Released identity after completing PR-010
[White] PR-005: Blocked-Ready → In Progress [AuthService.ts, UserModel.ts]
[Pink] PR-007: In Progress → Complete [AuthService.ts, SessionManager.ts]
[Pink] Released identity after completing PR-007
[White] PR-005: Planning → Blocked-Ready [AuthService.ts, UserModel.ts]
[White] Claimed identity for PR-005
# PR Timeout and Abandonment Policy

Agents can crash, run out of context, lose network connectivity, or get stuck. When this happens, their claimed PRs remain "In Progress" indefinitely, blocking files and preventing other agents from using them.

This policy defines when a PR is considered abandoned and how to reclaim it.

## Time Limits

### PR Status Timeouts

| Status | No Commits For | Action |
|--------|----------------|--------|
| In Progress | 2 hours | May be reclaimed as abandoned |
| Suspended | 24 hours | May be reclaimed as abandoned |

**Note:** The 2-hour timeout for In Progress PRs assumes normal development work. Complex debugging sessions may legitimately take longer.

### Agent Identity Timeouts

| Identity Status | No Commits For | Action |
|-----------------|----------------|--------|
| In Use | 12 hours | May be marked Timed Out and reclaimed |

## When Timeouts Don't Apply

### Legitimate Long-Running Work

Some tasks legitimately take longer than 2 hours:
- **Deep debugging sessions** - Tracking down elusive bugs, analyzing stack traces, testing hypotheses
- **Complex refactors** - Large-scale code reorganization with many interdependencies
- **Performance investigations** - Profiling, benchmarking, optimization iterations

### User Guidance for Long Work

If you know work will exceed the timeout:

**Option 1: Suspend and resume**
```bash
# After 90 minutes of debugging PR-015
# Mark as Suspended with detailed notes
# Release your identity
# Resume later with fresh context
```

**Option 2: Avoid running other agents in parallel**
- Don't spin up additional agents during deep debugging
- This prevents timeout conflicts entirely
- Resume parallel work when debugging is complete

**Option 3: Provide explicit guidance**
```bash
# When starting another agent while debugging is ongoing
claude /work

You: "Avoid PR-015, I'm actively debugging it in another session.
     Pick from PR-016, PR-017, or PR-018 instead."
```

The agent will respect your guidance and won't reclaim PR-015 even if it's technically timed out.

## Detecting Abandoned PRs

Before reclaiming a PR, verify it's actually abandoned:

```bash
# Check for recent commits on PR-XXX
git log --since="2 hours ago" --all-match --grep="PR-XXX" -- docs/task-list.md

# Check for recent commits by a specific agent identity
git log --since="2 hours ago" --all-match --grep="\[White\]" -- docs/task-list.md
```

**If no commits found:** PR or identity may be abandoned.

**If commits found:** Still active, do NOT reclaim.

## Reclaiming an Abandoned PR

### Step 1: Verify Timeout

Check the last commit timestamp for the PR:

```bash
git log --all-match --grep="PR-015" -- docs/task-list.md | head -20
```

If the most recent commit is >2 hours old (for In Progress) or >24 hours old (for Suspended), it may be reclaimed.

### Step 2: Check with User (Optional but Recommended)

If you're uncertain whether work is abandoned or just taking longer than expected, ask:

```
I see PR-015 has been In Progress for 3 hours with no commits.
Should I reclaim it as abandoned, or is debugging still ongoing?
```

This prevents accidentally reclaiming a legitimate long-running session.

### Step 3: Mark as Suspended (Reclaimed)

Update task-list.md:

```markdown
### PR-015: Fix Authentication Token Refresh Bug
**Status:** Suspended
**Last Agent:** White (reclaimed by Orange due to timeout)
**Files:** src/auth/AuthService.ts (modify)

**Suspended Notes:**
Reclaimed by [Orange] after 2+ hours of no activity. Original agent (White)
started debugging at 10:00 AM but no commits since 10:15 AM.

Partial work review:
- AuthService.ts has some debug logging added but no fix committed
- Git working directory was clean at time of reclaim
- To resume: review the auth token refresh logic, likely issue in expiration check

**Reclaim Timestamp:** 2025-10-27 12:30
```

### Step 4: Commit the Reclaim

```bash
git add docs/task-list.md
git commit -m "[Orange] PR-015: In Progress → Suspended (reclaimed due to timeout)

White started this PR at 10:00 AM but no commits in 2+ hours.
Marking as Suspended so files can be reclaimed if needed.
Added notes on current state for whoever resumes."
```

### Step 5: You Can Now Work on It

If you want to resume this PR yourself:

```bash
# Immediately after reclaiming as Suspended
# Change to In Progress under your identity

[Orange] PR-015: Suspended → In Progress [AuthService.ts]

Resuming abandoned work. Reviewed partial changes and will continue debugging.
```

Or leave it Suspended for another agent to pick up later.

## Reclaiming an Agent Identity

If an identity has been "In Use" for 12+ hours with no commits:

### Step 1: Check Activity

```bash
git log --since="12 hours ago" --all-match --grep="\[White\]" -- docs/task-list.md
```

### Step 2: Mark as Timed Out

Update agent-identity-lock.md:

```markdown
| White | Timed Out | 2025-10-27 02:15 | PR-015 |
```

Commit:
```bash
[Orange] Marked White identity as timed out (no activity in 12+ hours)
```

### Step 3: Reclaim It

Update agent-identity-lock.md:

```markdown
| White | In Use | 2025-10-27 14:30 | PR-020 |
```

Commit:
```bash
[Orange] Reclaimed White identity for PR-020
```

## Best Practices for Agents

### Commit Frequently During Long Work

Even if your implementation isn't complete, commit partial work every 30-45 minutes:

```bash
# After 45 minutes of debugging
git add src/auth/AuthService.ts
git commit -m "WIP: Add debug logging to token refresh flow

Still investigating why refresh returns 401. Added extensive logging
around expiration check and token validation. Not ready for testing yet.

Part of PR-015."

# Update task-list.md with progress note
[White] PR-015: Added debug logging, still investigating (45 min elapsed)
```

This:
- Prevents timeout reclaim
- Shows you're actively working
- Provides recovery point if you crash
- Helps next agent understand current state

### Mark as Suspended When Pausing

If you need to pause work for any reason:

```bash
# Going to lunch, taking a break, switching context

[White] PR-015: In Progress → Suspended [AuthService.ts]

Pausing after 90 minutes of debugging. Current findings:
- Token expiration check uses <= when it should use <
- Haven't confirmed fix yet, need to write test
- Resume by writing test case for edge condition

Suspended at: 12:00 PM, will resume after lunch.
```

Then release your identity:

```bash
[White] Released identity (PR-015 suspended for lunch break)
```

### Release Identity When Complete

Always release your identity when completing or abandoning work:

```bash
[White] PR-015: In Progress → Complete [AuthService.ts, test/auth.test.ts]
[White] Released identity after completing PR-015
```

## Why These Timeouts?

- **2 hours for In Progress:** Most implementation work completes in 30-90 minutes. 2 hours is generous buffer while still preventing indefinite locks.

- **24 hours for Suspended:** Suspended work might be waiting for user input, design decisions, or dependencies. Longer timeout accounts for timezone differences and async collaboration.

- **12 hours for identities:** Agents typically work within a single session (1-4 hours). 12 hours allows multi-session work while preventing abandoned identities from permanently consuming slots.

## User Responsibilities

As the user coordinating multiple agents:

1. **Be aware of timeouts** - Don't be surprised if an abandoned PR gets reclaimed
2. **Provide guidance** - Tell new agents to avoid PRs you're actively working on
3. **Monitor activity** - Use `/status` command to see what's In Progress
4. **Avoid excessive parallelism** - More than 3-4 simultaneous agents increases collision likelihood

## Edge Case: User is Actively Working

If the **user** is working on a PR directly (not through /work command):

**User should create a placeholder commit:**

```bash
# User starts working on PR-022 manually
# Claim it in task-list.md

git add docs/task-list.md
git commit -m "[User] PR-022: New → In Progress [components/Dashboard.tsx]

Working on this directly, not via /work command. Other agents should avoid."
```

Then commit progress periodically to prevent timeout reclaim:

```bash
[User] PR-022: Work in progress (1 hour elapsed, implementing dashboard layout)
```

## Summary

Timeouts prevent abandoned work from blocking progress:

- **In Progress:** 2 hours → reclaim (unless deep debugging)
- **Suspended:** 24 hours → reclaim
- **Identity:** 12 hours → reclaim

When in doubt:
- Check git log for recent activity
- Ask user before reclaiming
- Commit frequently to signal you're active
- Mark as Suspended when pausing

See also:
- `.claude/rules/agent-identity.md` - Identity claiming and release
- `.claude/rules/race-conditions.md` - Preventing simultaneous claims
- `.claude/rules/atomic-commits.md` - Commit discipline

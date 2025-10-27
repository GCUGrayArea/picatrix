# Race Condition Resolution

When multiple agents work in parallel, they may simultaneously try to claim the same PR or modify the same coordination document. This causes git merge conflicts. This document explains how to detect and resolve these conflicts.

## What is a Race Condition?

A race condition occurs when two agents try to modify the same line in a coordination document at the same time:

```
10:00:00 AM: White reads task-list.md (PR-005 is "New")
10:00:00 AM: Orange reads task-list.md (PR-005 is "New")
10:01:15 AM: White commits: PR-005 New → Planning
10:01:20 AM: Orange tries to commit: PR-005 New → Planning
             ❌ Git conflict: both modified the same line
```

## Prevention: Always Pull Before Claiming

**CRITICAL: Before claiming any PR, always sync with the remote repository.**

```bash
# Always do this before claiming a PR
git pull --rebase
```

This ensures you see the latest state, including any claims made by other agents in the last few seconds.

## Detection: Git Push Failure

If you try to push a commit and see:

```
! [rejected]        main -> main (fetch first)
error: failed to push some refs
```

This means another agent pushed changes while you were working. You need to sync and potentially resolve a conflict.

## Resolution Process

### Step 1: Fetch Latest Changes

```bash
git pull --rebase
```

### Step 2: Check for Conflicts

If there are no conflicts, git will automatically merge and you're done. If there ARE conflicts, you'll see:

```
CONFLICT (content): Merge conflict in docs/task-list.md
```

### Step 3: Read the Conflict

Open the conflicted file and look for conflict markers:

```markdown
<<<<<<< HEAD (your changes)
### PR-005: Implement User Authentication
**Status:** Planning - [White]
=======
### PR-005: Implement User Authentication
**Status:** Planning - [Orange]
>>>>>>> main (their changes)
```

### Step 4: Decide Who Wins

**General Rule: First committer wins.**

Check the timestamps:
- If the other agent committed first (their timestamp is earlier), **they win**
- Back out your claim and select a different PR

**How to resolve:**

```markdown
# Keep their version, discard yours
### PR-005: Implement User Authentication
**Status:** Planning - [Orange]  ← They got here first
```

Then:
```bash
git add docs/task-list.md
git rebase --continue
```

Now select a different PR to work on.

### Step 5: Commit Resolution

If you had to resolve a conflict, commit a note:

```bash
git commit --allow-empty -m "[White] Resolved race condition on PR-005

Orange claimed PR-005 first. Backing off and will select different PR."
```

## Special Cases

### Conflict on Different PRs

If you and another agent modified different PRs in task-list.md, both changes can coexist:

```markdown
<<<<<<< HEAD
### PR-005: User Authentication
**Status:** Planning - [White]
=======
### PR-008: Payment Gateway
**Status:** Planning - [Orange]
>>>>>>> main
```

**Resolution:** Keep both changes
```markdown
### PR-005: User Authentication
**Status:** Planning - [White]

### PR-008: Payment Gateway
**Status:** Planning - [Orange]
```

### Conflict on Identity Lock

If two agents try to claim the same identity simultaneously:

```markdown
<<<<<<< HEAD
| White | In Use | 2025-10-27 10:15 | PR-005 |
=======
| White | In Use | 2025-10-27 10:15 | PR-008 |
>>>>>>> main
```

**Resolution:** First committer wins, second agent picks a different identity.

```markdown
# Keep their version
| White | In Use | 2025-10-27 10:15 | PR-008 |
```

Then claim a different available identity (Orange, Blonde, Pink, Blue, or Brown).

## Never Force Push

**NEVER use `git push --force` to resolve conflicts.**

Force pushing overwrites other agents' work and breaks coordination. Always resolve conflicts manually and commit the resolution.

## Best Practices

1. **Pull before claiming:** Always `git pull --rebase` before modifying coordination documents
2. **Commit quickly:** Don't leave uncommitted coordination changes sitting around
3. **Check timestamps:** In conflicts, respect chronological order
4. **Back off gracefully:** If someone beat you to a PR, pick a different one
5. **Document resolutions:** Add a note explaining why you backed off

## Prevention Through Atomic Commits

Following the atomic commit policy (atomic-commits.md) helps prevent race conditions:

- Small, focused commits reduce window for conflicts
- Immediate commits make your claims visible faster
- Clear commit messages help resolve conflicts when they occur

## Example: Full Resolution Workflow

```bash
# Agent White wants to claim PR-005

# Step 1: Pull latest
git pull --rebase
# ✓ Already up to date

# Step 2: Read and modify task-list.md
# Change PR-005 from "New" to "Planning - [White]"

# Step 3: Commit
git add docs/task-list.md
git commit -m "[White] PR-005: New → Planning [AuthService.ts, UserModel.ts]"

# Step 4: Try to push
git push
# ❌ Error: rejected (fetch first)

# Step 5: Pull again to get their changes
git pull --rebase
# ⚠️ CONFLICT in docs/task-list.md

# Step 6: Check the conflict
cat docs/task-list.md
# Shows: Orange also claimed PR-005, committed 30 seconds ago

# Step 7: Resolve - Orange won
# Keep Orange's version, discard White's claim

git add docs/task-list.md
git rebase --continue

# Step 8: Pick different PR
# Modify task-list.md: PR-007 New → Planning - [White]

git add docs/task-list.md
git commit -m "[White] PR-007: New → Planning [Dashboard.tsx, hooks/useDashboard.ts]

Resolved race condition: Orange claimed PR-005 first, selected PR-007 instead."

git push
# ✓ Success
```

## Summary

Race conditions are normal in parallel agent work. The key is:

1. **Pull before claiming** - reduces likelihood of conflicts
2. **First wins** - respect chronological order in conflicts
3. **Back off gracefully** - pick a different PR if someone beat you to it
4. **Never force push** - always resolve manually

These simple rules keep agents coordinated without centralized locking.

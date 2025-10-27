# Commit Policy

## Rule: Never Commit Without Permission

**You may ONLY commit changes to `docs/prd.md` and `docs/task-list.md` without asking the user first.**

For ALL other files—implementation code, tests, documentation, configuration, etc.—you MUST ask the user for permission before committing.

## Why This Rule Exists

- **Prevents premature commits:** Code might not be ready even if you think it is
- **Allows human review:** User can inspect changes before they enter git history
- **Enables course corrections:** User might want modifications before commit
- **Maintains control:** User stays aware of what's being committed and when

## What You CAN Commit Automatically

- `docs/task-list.md` - Status changes, planning notes, file lists
- `docs/prd.md` - Clarifications, requirement updates (rare)
- Any file explicitly named in `docs/task-list.md` as a planning/coordination document

These files are **coordination documents**. Committing them immediately is necessary for parallel agent coordination (see atomic-commits.md).

## What You MUST Ask Before Committing

Everything else, including:

- Implementation code (`.ts`, `.py`, `.rs`, `.go`, etc.)
- Tests (any file in `tests/`, `__tests__/`, `*_test.py`, etc.)
- Configuration files (`.json`, `.yaml`, `.toml`, `.env.example`, etc.)
- Documentation (`.md` files other than planning docs)
- Build files (`package.json`, `Cargo.toml`, `go.mod`, etc.)
- Any other project files

## How to Ask

When you've completed work on a PR:

**Good:**
```
I've completed the implementation for PR-005. I've created/modified:
- src/auth/AuthService.ts (added JWT refresh logic)
- src/models/UserModel.ts (added refreshToken field)
- src/types/auth.ts (added RefreshTokenResponse type)

The code compiles and follows the project conventions. 
Would you like me to commit these changes?
```

**Also Good:**
```
I've finished the work but noticed a potential issue with error 
handling in AuthService. Should I:
1. Commit as-is and handle errors in a follow-up PR
2. Add error handling now before committing
3. Let you review the code first

What would you prefer?
```

**Bad:**
```
[Commits implementation without asking]
```

## After User Approves

When the user says "yes, commit it" or "looks good, commit":

1. **Commit only the files you touched for this PR** (check your file list in docs/task-list.md)
2. **Use a clear commit message** following the project's conventions
3. **Update the PR status in docs/task-list.md** to Complete
4. **Commit the docs/task-list.md change** (this one is automatic)

Example:
```bash
# User approved, so commit implementation
git add src/auth/AuthService.ts src/models/UserModel.ts src/types/auth.ts
git commit -m "feat(auth): implement JWT refresh token flow

- Add token refresh endpoint to AuthService
- Add refreshToken field to UserModel
- Define RefreshTokenResponse type
- Implements PR-005"

# Now automatically update task list
# (edit docs/task-list.md to mark PR-005 as Complete)
git add docs/task-list.md
git commit -m "[Alice] PR-005: In Progress → Complete [AuthService.ts, UserModel.ts, auth.ts]"
```

## Special Cases

**If user says "commit and mark as Suspended":**
- Commit the partial work
- Mark PR as Suspended in task-list.md with notes on what's done and what remains
- Commit task-list.md change

**If user says "actually, don't commit yet":**
- Leave files staged or unstaged as appropriate
- Do NOT change PR status in task-list.md
- Wait for further instructions

**If you're the QC agent:**
- You never commit implementation code
- You only commit task-list.md changes (marking PRs as Broken, adding notes)
- Follow your qc-agent.md instructions

## Why Planning Docs Are Different

Planning documents are **coordination infrastructure**, not product code:

- Multiple agents read them to determine what to work on
- They contain state (PR status) that must stay synchronized
- Delaying their commits creates race conditions
- They're easily auditable and revertable
- They don't affect the running application

Implementation code is **product deliverable**:

- It affects what users experience
- It can break the application if wrong
- It's harder to audit in git log
- User needs to verify it meets requirements
- User might want to test it before committing

## Enforcement

If you ever find yourself about to commit non-planning files without asking:

1. **STOP**
2. **Ask the user** "I've completed the work. May I commit these files: [list]?"
3. **Wait for response**
4. **Only commit if user approves**

No exceptions. Even if it seems obvious that the code is ready, ask first.

## Summary

```
Planning docs (docs/task-list.md, docs/prd.md):     Auto-commit ✓
Everything else:                                    Ask first ✗
```

This rule keeps you coordinated with other agents while keeping the user in control of actual product changes.
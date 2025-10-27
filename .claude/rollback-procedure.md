# Rollback Procedure

Sometimes completed code needs to be undone—not because it's buggy, but because the approach was wrong, requirements changed, or it's no longer needed.

This document explains when and how to roll back a completed PR.

## When to Rollback vs Fix

### Mark as Broken (Fix in Place)

Use when code **should work but doesn't:**
- Bug in implementation
- Tests failing
- Incorrect logic
- Missing edge case handling
- Performance regression

**Action:** Mark PR as Broken, fix the issue, return to Complete.

### Rollback (Create Revert PR)

Use when the code **works as intended but shouldn't exist:**
- Wrong architectural approach
- Requirements changed
- Feature no longer needed
- Dependency being removed
- Better solution discovered

**Action:** Create new "Revert PR-XXX" PR, mark original as Reverted.

## Example Scenarios

### Scenario 1: Should Fix, Not Rollback

```
PR-015: Implement Redis Caching
Status: Complete → Broken

QC found: Cache returns stale data after TTL expires.

This is a BUG. The Redis implementation should work but has incorrect
TTL logic. FIX IT, don't roll it back.
```

### Scenario 2: Should Rollback, Not Fix

```
PR-015: Implement Redis Caching
Status: Complete → Reverted

User decision: Redis is overkill for current scale (1K users).
Switch to in-memory cache instead.

This isn't a bug—Redis works fine. But the APPROACH was wrong for
the requirements. ROLL IT BACK and implement simpler solution.
```

## PR Status: Reverted

When rolling back a PR, add a new status to the PR states:

- New
- Planning
- Blocked-Ready
- In Progress
- Suspended
- Complete
- Broken
- **Reverted** ← New status

## Rollback Workflow

### Step 1: Mark Original PR as Reverted

Update docs/task-list.md:

```markdown
### PR-015: Implement Redis Caching
**Status:** Reverted (see PR-032)
**Original Completion:** 2025-10-27 14:00 by [Orange]
**Files:**
  - src/cache/RedisCache.ts (created)
  - src/config/redis.ts (created)
  - package.json (modified - added redis dependency)

**Revert Reason:**
Redis dependency is overkill for current scale (1K users, low cache hit rate).
User decided to use simple in-memory cache with Map instead. Redis works
correctly but approach doesn't fit requirements.

**Reverted By:** PR-032
**Reverted Date:** 2025-10-28 10:00
```

Commit:
```bash
[White] PR-015: Complete → Reverted [see PR-032 for revert]

User requested rollback. Redis implementation works but is overkill for
current requirements. Will replace with in-memory cache in PR-032.
```

### Step 2: Create Revert PR

Add new PR to docs/task-list.md:

```markdown
### PR-032: Revert Redis Caching, Implement In-Memory Cache
**Status:** New
**Dependencies:** PR-015 must be Complete to revert it
**Priority:** High
**Reverts:** PR-015

**Description:**
Remove Redis caching implementation and replace with simple in-memory
cache using JavaScript Map with TTL. Redis works fine but is unnecessary
complexity for our current scale (1K users, ~100 cache entries).

**Files:**
  - src/cache/RedisCache.ts (delete)
  - src/config/redis.ts (delete)
  - src/cache/MemoryCache.ts (create)
  - package.json (modify - remove redis dependency)
  - docs/architecture.md (update - document cache strategy change)

**Acceptance Criteria:**
- [ ] Redis files and dependency removed
- [ ] MemoryCache implements same interface as RedisCache
- [ ] TTL expiration working correctly
- [ ] All cache-related tests updated and passing
- [ ] No references to Redis remain in codebase

**Implementation Notes:**
- Keep the same cache interface so calling code doesn't change
- Use Map with setTimeout for TTL expiration
- Consider max size limit (evict LRU entries if >1000 items)
- Migration path: no data migration needed (cache is ephemeral)
```

Commit:
```bash
[White] Created PR-032 to revert PR-015 and implement in-memory cache

User requested rollback of Redis approach. PR-032 will remove Redis
and replace with simpler Map-based cache.
```

### Step 3: Implement Revert PR

Agent claims PR-032 and implements it like any other PR:

```bash
# Agent claims PR-032
[Blonde] PR-032: New → Planning

# Agent plans the work
[Blonde] PR-032: Planning → In Progress [RedisCache.ts, MemoryCache.ts, package.json, redis.ts]

# Agent implements the revert
- Delete src/cache/RedisCache.ts
- Delete src/config/redis.ts
- Create src/cache/MemoryCache.ts
- Remove redis from package.json
- Update tests
- Update docs

# Agent completes
[Blonde] PR-032: In Progress → Complete [reverted Redis, implemented MemoryCache]

Removed Redis dependency and implementation. Created MemoryCache using
Map with TTL. All tests passing. Coverage: 96%.
```

## Git Operations for Rollback

### Option A: Literal Git Revert (Rare)

If the original PR was a single clean commit, you can use git revert:

```bash
# Find the commit hash for PR-015
git log --grep="PR-015" --grep="Complete" --all-match

# Revert that commit
git revert <commit-hash>

# This creates a new commit that undoes PR-015's changes
```

**When to use:** Single commit, clean revert, no subsequent changes to those files.

### Option B: Manual Undo (More Common)

Usually better to manually delete/modify files:

```bash
# Just delete the files you want to remove
rm src/cache/RedisCache.ts
rm src/config/redis.ts

# Edit package.json to remove redis dependency
# Create new MemoryCache.ts
# Update tests

git add .
git commit -m "Revert PR-015: Remove Redis, implement MemoryCache

Removed Redis caching implementation per user request.
Replaced with in-memory Map-based cache with TTL.

Implements PR-032."
```

**When to use:** Most cases, especially when other PRs have touched the same files since PR-015.

## When NOT to Rollback

### Partial Revert Not Needed

If only **part** of a PR needs to change, don't create a revert PR. Just create a new PR to modify it:

```markdown
PR-015: Implement Redis Caching - Complete
PR-033: Add Redis connection pooling - New  ← Incremental improvement, not revert
```

### Broken Code

If code is **buggy**, mark it Broken and fix it. Don't revert working features just because of a bug:

```markdown
❌ Bad: PR-032 Revert authentication (has bug in token refresh)
✅ Good: Mark PR-015 as Broken, fix token refresh bug, return to Complete
```

### Dependency Chain

If other PRs depend on the reverted PR, you may need to revert them too:

```
PR-015: Redis Caching - Complete
PR-018: Redis Session Storage (depends on PR-015) - Complete
PR-022: Redis Rate Limiting (depends on PR-015) - Complete

If reverting PR-015, also need to revert PR-018 and PR-022
OR find alternative implementations for sessions and rate limiting.
```

## Rollback Checklist

Before creating a revert PR:

- [ ] Confirm the original PR works correctly (not broken, just wrong approach)
- [ ] Get user approval for the rollback decision
- [ ] Check if other PRs depend on this one
- [ ] Mark original PR status as "Reverted" with clear reason
- [ ] Create new revert PR with specific files to delete/modify
- [ ] Link revert PR to original PR in both directions
- [ ] Ensure revert PR has complete acceptance criteria
- [ ] Consider data migration needs (usually none for infrastructure changes)

## Communicating Reverts

### In PR Notes

Always explain **why** the revert is happening:

```markdown
**Revert Reason:** ✅ GOOD
Requirements changed. Originally planned for 100K users, now targeting
1K users. Redis adds complexity without benefit at this scale.

**Revert Reason:** ❌ BAD
Redis doesn't work.
(This should be "Broken" status, not reverted)
```

### In Commit Messages

Be clear that this is an architectural decision, not a bug fix:

```bash
✅ GOOD:
[White] PR-015: Complete → Reverted [architectural decision]

User confirmed Redis is overkill for current scale. Will replace with
in-memory cache in PR-032. Original implementation worked correctly.

❌ BAD:
[White] PR-015: Complete → Reverted

(No explanation, looks like it failed)
```

## Summary

| Situation | Status Change | Next Steps |
|-----------|---------------|------------|
| Bug in code | Complete → Broken | Fix bug, return to Complete |
| Wrong approach | Complete → Reverted | Create revert PR, implement alternative |
| No longer needed | Complete → Reverted | Create revert PR to delete |
| Partial change needed | Keep Complete | Create new PR for modification |

**Reverted status is not a failure.** It's a normal part of iterative development. Requirements change, better solutions emerge, and code needs to adapt.

The revert PR process ensures:
- Clear audit trail of why code was removed
- Proper testing of the removal
- Documentation of architectural decisions
- No rushed deletions without review

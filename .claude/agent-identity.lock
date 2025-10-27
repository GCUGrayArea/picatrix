# Agent Identity Lock

This file tracks which agent identities are currently in use. Agents must claim an identity before starting work and release it when done.

**Last Updated:** Never (template)

## Available Identities

| Identity | Status | Last Commit | Current PR |
|----------|--------|-------------|------------|
| White    | Available | - | - |
| Orange   | Available | - | - |
| Blonde   | Available | - | - |
| Pink     | Available | - | - |
| Blue     | Available | - | - |
| Brown    | Available | - | - |

## Special Identities

- **QC** - Quality Control agent (does not use lock system)

## Rules

1. **Claiming:** Take the first Available identity, change status to "In Use", add timestamp and PR number
2. **Releasing:** When completing or suspending your PR, change status back to "Available"
3. **Timeout:** Identities with no commits in 12+ hours may be reclaimed
4. **Commit immediately:** Every change to this file must be committed atomically (see atomic-commits.md)

## Status Values

- **Available** - No agent using this identity
- **In Use** - Agent actively working (includes timestamp, PR number)
- **Timed Out** - No commits in 12+ hours, may be reclaimed

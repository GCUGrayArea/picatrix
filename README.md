## Picatrix: Multi-Agent Claude Code Coordination Template

A meta-repository template for running multiple Claude Code agents in parallel with automatic coordination, source control safety, and quality control.

## Features

- **Parallel agent coordination** - Up to 6 agents working simultaneously without conflicts
- **File locking** - Prevents agents from interfering with each other's work
- **Automatic QC** - Quality control agent tests completed work
- **Source control safety** - Atomic commits, race condition resolution, commit policies
- **Planning workflow** - Generates PRD and task list from specs
- **Persistent context memory** - Memory bank accumulates implementation knowledge across sessions

## Setup

1. **Fork this meta-repo** for your new project
2. **Install Claude Code essentials plugin:**
   ```bash
   /plugin marketplace add https://github.com/wshobson/agents
   ```
3. **Initialize your project:**
   ```bash
   /plan <path-to-spec>
   ```
   This generates `docs/prd.md` and `docs/task-list.md` from your specification.

4. **Start parallel agents with `/work`:**
   ```bash
   # In terminal 1
   claude /work

   # In terminal 2
   claude /work

   # In terminal 3
   claude /work
   ```

5. **Monitor progress:**
   ```bash
   /status
   ```

6. **Run quality control:**
   ```bash
   /qc
   ```

## Important User Documentation

**READ THESE if you're running parallel agents:**

- **`.claude/timeout-policy.md`** - PR timeout rules, when agents can reclaim abandoned work, how to handle long debugging sessions
- **`.claude/agent-identity.md`** - How agents claim and release identities (White, Orange, Blonde, Pink, Blue, Brown)
- **`.claude/race-conditions.md`** - How agents avoid claiming the same PR simultaneously
- **`.claude/emergency-stop.md`** - How to halt all agents immediately with `/halt` and resume with `/resume`

These documents contain important information about edge cases and best practices.

## Workflow Overview

1. **Planning Agent** (`/plan`) - Reads spec, generates PRD and task list
2. **Work Agents** (`/work`) - Claim identity, select PR, implement, commit, release identity
3. **QC Agent** (`/qc`) - Tests completed PRs, marks as Broken/Approved/Certified

## Agent Coordination Files

- `docs/prd.md` - Product Requirements Document
- `docs/task-list.md` - PR task list with statuses and file locks
- `docs/memory/*.md` - Memory bank (systemPatterns, techContext, activeContext, progress)
- `.claude/agent-identity.lock` - Tracks which agent identities are in use

These files are auto-committed by agents. Implementation code always requires user approval before committing.

## Example Workflow

See `docs/example-task-list.md` for a realistic example of what task-list.md looks like during active development.

## Commands

- `/plan <spec>` - Generate PRD and task list from specification
- `/work` - Start agent work session (claims identity, selects PR, implements)
- `/qc` - Run quality control on completed PRs
- `/status` - Show current project status
- `/halt [reason]` - Emergency stop all running agents (suspends work, releases identities)
- `/resume` - Resume normal operations after halt

## Customizing for Your Project

Once you've initialized with `/plan` and started development:

1. Replace this README with your project-specific README
2. The `.claude/` directory contains the coordination rules
3. The `docs/` directory contains your PRD, task list, and memory bank (implementation knowledge)

## Architecture

For details on how parallel agent coordination works, see:

- `.claude/rules/agent-defaults.md` - Agent workflow and rules
- `.claude/rules/coding-standards.md` - Code quality standards (function/file size limits, etc.)
- `.claude/rules/memory-bank.md` - Persistent context system
- `.claude/rules/atomic-commits.md` - Commit discipline for coordination
- `.claude/rules/commit-policy.md` - What agents can commit automatically
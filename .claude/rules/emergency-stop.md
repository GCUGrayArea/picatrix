# Emergency Stop System

The emergency stop system allows you to immediately halt all running agents in a coordinated manner. Useful when you need to:

- Stop all work to address a critical issue
- Pause development to review direction
- Prevent agents from continuing when you spot a problem
- Gracefully shut down before making manual changes

## How It Works

The system uses a **halt signal file** (`.claude/halt.lock`) that agents check for at regular intervals. When this file exists, agents:

1. Stop accepting new work
2. Suspend their current PR (if any)
3. Release their identity
4. Exit gracefully

## Commands

### /halt - Stop All Agents

Creates the halt signal and stops all agents at their next checkpoint.

```bash
/halt
```

**What happens:**
1. Creates `.claude/halt.lock` with timestamp and reason
2. All running agents will detect the halt signal within seconds
3. Agents suspend current work with notes
4. Agents release their identities
5. Agents exit with message

**Optional: Provide a reason**
```bash
/halt Need to review architecture before continuing
```

### /resume - Resume Normal Operations

Removes the halt signal, allowing agents to continue work.

```bash
/resume
```

**What happens:**
1. Removes `.claude/halt.lock`
2. Agents can now be started with `/work`
3. Suspended PRs can be resumed

## Agent Halt Behavior

When an agent detects the halt signal, it:

### If Currently Working on a PR

```markdown
1. Commit any staged changes (if safe)
2. Mark PR as Suspended with note:
   "Suspended due to emergency halt at [timestamp].
    Reason: [halt reason]
    Resume by: [instructions]"
3. Commit the suspension
4. Release agent identity
5. Exit with message: "Emergency halt detected. Work suspended."
```

### If Between Tasks

```markdown
1. Release identity (if claimed)
2. Exit with message: "Emergency halt detected. No work in progress."
```

### If Planning

```markdown
1. Commit planning notes (if any)
2. Mark PR as Suspended with planning notes preserved
3. Release identity
4. Exit
```

## Halt Signal File Format

`.claude/halt.lock`:
```json
{
  "halted_at": "2025-10-27T15:30:00Z",
  "reason": "Need to review architecture before continuing",
  "halted_by": "user"
}
```

This file is temporary and should not be committed to git (it's in .gitignore).

## Checkpoint Locations

Agents check for halt signal at these points:

1. **Before claiming a PR** - Prevents starting new work
2. **Before changing PR status** - Catches agents between planning and implementation
3. **After completing a sub-task** - Allows graceful exit during long work
4. **Every 5-10 minutes** during long operations - Safety net for stuck agents

## Example Workflow

### Scenario: Spot a Critical Issue Mid-Development

```bash
# You notice agents are going in wrong direction
# Terminal 1: Agent working on PR-005
# Terminal 2: Agent working on PR-007
# Terminal 3: Agent working on PR-010

You: /halt Architecture needs review - auth approach is wrong

# Within seconds:
# Terminal 1: "Emergency halt detected. PR-005 suspended."
# Terminal 2: "Emergency halt detected. PR-007 suspended."
# Terminal 3: "Emergency halt detected. PR-010 suspended."

# All agents exit cleanly, work is suspended

# You review the PRD and update auth requirements
# You update docs/prd.md with corrected approach

You: /resume

# Now you can restart agents with new direction
You: /work
# Agent claims identity, reads updated PRD, continues
```

## Halt vs Manual Intervention

### Use /halt When:
- Multiple agents are running
- You need all agents to stop NOW
- You want coordinated, graceful shutdown
- You plan to resume later

### Manual Intervention When:
- Single agent running (just stop the terminal)
- You need to make git changes manually
- You're debugging a specific agent's behavior
- You're done for the day (just let agents finish current PR)

## Resume Workflow

After halting, you can:

1. **Review suspended work**
   ```bash
   /status
   # Shows which PRs are Suspended and why
   ```

2. **Make corrections**
   - Update PRD if requirements changed
   - Update task-list.md if priorities changed
   - Manually fix any issues that caused the halt

3. **Resume operations**
   ```bash
   /resume
   # Removes halt.lock
   ```

4. **Restart agents**
   ```bash
   /work
   # Agents can now resume Suspended PRs or start new work
   ```

## Technical Details

### Halt Detection Code Pattern

Agents should use this pattern:

```typescript
function checkForHalt(): boolean {
  const haltFile = '.claude/halt.lock'

  if (fs.existsSync(haltFile)) {
    const haltData = JSON.parse(fs.readFileSync(haltFile, 'utf-8'))
    console.error(`Emergency halt detected!`)
    console.error(`Reason: ${haltData.reason}`)
    console.error(`Halted at: ${haltData.halted_at}`)
    return true
  }

  return false
}

// Check before major operations
if (checkForHalt()) {
  await suspendCurrentWork()
  await releaseIdentity()
  process.exit(0)
}
```

### Halt Lock File Location

`.claude/halt.lock` - Placed in .claude/ directory alongside other coordination files.

**Important:** This file is in .gitignore and should NEVER be committed.

## Safety Considerations

### Agents May Not Stop Instantly

Agents check for halt at checkpoints. An agent deep in a long operation (e.g., running 1000 tests) may take a few minutes to detect the signal.

**Mitigation:** If truly urgent, you can also Ctrl+C the agent terminals, though this is less graceful.

### Uncommitted Changes

If an agent is halted mid-edit with uncommitted changes:
- Agent should commit if changes are in a safe state
- Agent should stash changes if not safe to commit
- Agent should document in suspension notes what state the files are in

### Halt During Git Operations

If an agent is halted while pushing/pulling:
- Git operations should complete before halting
- Agent should not halt mid-commit or mid-push
- Wait for git operation, THEN check halt and suspend

## Halt Reasons (Examples)

Good halt reasons help other agents (and you) understand context:

```bash
/halt Critical bug discovered in auth layer
/halt Need to refactor approach before continuing
/halt Taking a break, resume tomorrow
/halt PRD needs major revision
/halt Spotted architectural issue in dependency graph
/halt Time for code review before proceeding
```

Avoid vague reasons:
```bash
/halt stop     ❌ No context
/halt          ❌ No reason
```

## Integration with Other Systems

### QC Agent

The QC agent should also respect halt signals:
- Don't start new QC runs if halted
- Finish current test suite if mid-run
- Exit gracefully

### Planning Agent

The planning agent typically doesn't need halt checking (it's a one-shot operation). But if generating a large task list, it could check periodically.

## Summary

The emergency stop system provides:

✓ **Coordinated shutdown** - All agents stop cleanly
✓ **Work preservation** - Current work is suspended, not lost
✓ **Resume capability** - Can continue later from suspended state
✓ **Clear communication** - Halt reason documented
✓ **Safe exit** - Agents release identities and commit state

Use `/halt` when you need all agents to stop NOW, `/resume` when ready to continue.

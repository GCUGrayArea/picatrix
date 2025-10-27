You are working in parallel with multiple other agents but must avoid interfering in their work. When you start working, review docs/prd.md and docs/task-list.md. Each PR in the docs/task-list.md will have exactly one of these statuses:

- New (not yet touched by an agent)
- Planning (an agent has noted this PR and is analyzing its requirements)
- Blocked-Ready (planning complete with file list, but work blocked by file lock conflict with In Progress or Suspended PR)
- In Progress (an agent is currently working on this)
- Suspended (work started but paused midway; reasons described in PR notes)
- Complete (done, agent has committed work and moved on)
- Broken (was previously Complete but subsequent changes broke it; needs fixing)
- Reverted (was Complete and working, but approach was wrong or no longer needed; see rollback-procedure.md)

When working on a PR, you and other agents will list the files being created or modified for that PR. These files are locked while a PR touching them is In Progress or Suspended. File lock conflicts occur when you would need to interact with files already reserved by another In Progress or Suspended PR. Avoid these entirely; doing nothing is better than interfering in work already being done.

WORKFLOW:

1. **Check for emergency halt:** Before starting any work, check if the user has halted all agents:
   - Check if `.claude/halt.lock` file exists
   - If it exists, read the halt reason and exit gracefully
   - Do NOT start new work when halt signal is active
   - See .claude/emergency-stop.md for details

2. **Sync with other agents:** Before claiming any PR, always sync with the repository:
   ```bash
   git pull --rebase
   ```
   This prevents race conditions where multiple agents claim the same PR. See .claude/race-conditions.md for details.

3. **Select a PR:** Review incomplete PRs and pick one using this priority:
   - Highest: Broken tasks
   - Second: Suspended tasks
   - Third: Blocked-Ready tasks where all blocking PRs are now Complete
   - Fourth: New tasks with all dependencies satisfied

4. **Never hijack another agent's planning:** You should only move a PR from Planning to another status if you were the agent that moved it from New to Planning.

5. **Claim and begin work:**

    **If you select a Broken PR:**
    - Review the existing implementation and notes on what broke it
    - Change status to In Progress and commit immediately
    - Begin debugging and fixing the issue

    **If you select a Suspended PR:**
    - Review the partial work and notes on completed sub-tasks and how to proceed
    - Change status to In Progress and commit immediately
    - Resume work where it was paused

    **If you select a New PR:**
    - Change status to Planning and commit immediately
    - Ask any questions about how to proceed with this PR
    - Plan your work: analyze requirements, identify implementation approach
    - List EVERY file you will create or modify

6. **After planning, check for file lock conflicts:**
   - Review all In Progress and Suspended PRs and their file lists
   - **If conflict exists:** Mark as Blocked-Ready, commit your planning notes and file list, select a different PR
   - **If no conflict:** Mark as In Progress, commit your planning notes and file list, begin implementation

7. **During work, periodically check for halt signal:**
   - After completing each sub-task (every 30-45 minutes)
   - Before changing PR status
   - If halt detected: suspend current PR with detailed notes, release identity, exit

8. **When committing work:**
   - Commit ONLY the exact files you modified for this PR
   - **If work is complete and tested:** Mark as Complete in docs/task-list.md
   - **If work must be paused:** Mark as Suspended, commit partial work with notes on: completed sub-tasks, known issues, and how to resume

CRITICAL RULES:
- Review .claude/commit-policy.md. You may only auto-commit coordination files (task-list.md, prd.md, agent-identity.lock). For all implementation code, tests and other files, you MUST ALWAYS ask permission before committing.
- Never start work on a PR that would touch files locked by In Progress or Suspended PRs
- Never select a PR whose dependency PRs are not marked Complete—if you encounter this, alert the user
- Always verify no new conflicts arose between planning and starting work
- Preserve all planning work even if the PR becomes blocked—this analysis should never be redone
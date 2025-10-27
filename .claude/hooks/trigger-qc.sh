# Make this executable with chmod +x .claude/hooks/trigger-qc.sh

#!/bin/bash

# Parse the tool input to check if task-list.md was modified
FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE_PATH" != *"task-list.md"* ]]; then
  exit 0  # Not task list, skip QC trigger
fi

# Check if any PR was just marked Complete
NEWLY_COMPLETE=$(git diff HEAD~1 HEAD task-list.md | grep -E '^\+.*Status:.*Complete' | wc -l)

if [ "$NEWLY_COMPLETE" -eq 0 ]; then
  exit 0  # No new completions, skip QC
fi

# Extract which PR(s) were marked complete
PR_NUMBERS=$(git diff HEAD~1 HEAD task-list.md | grep -B10 -E '^\+.*Status:.*Complete' | grep -E 'PR-[0-9]+' | sed 's/.*\(PR-[0-9]\+\).*/\1/' | sort -u)

echo "QC Trigger: Detected newly completed PR(s): $PR_NUMBERS"

# Run QC agent in headless mode
claude --system-prompt-file .claude/commands/qc-agent.md -p "A PR was just marked Complete. Review task-list.md, test the newly completed PR(s): $PR_NUMBERS, and take appropriate action (mark Broken if tests fail, add coverage notes, or certify if 100% coverage)."

exit 0
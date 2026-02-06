---
name: multi-flow
description: Run the lightweight multi-agent MCP flow in parallel without creating Issue/PR. Triggers on "multi-flow", "マルチフロー", "並列軽量フロー", and similar requests.
---

# Multi Flow (Codex)

## Purpose
Use `multi-flow` when the user wants parallel multi-agent implementation with MCP but does not require Issue/PR lifecycle automation.

## When to Use
- User explicitly asks for `multi-flow` or equivalent terms.
- The task should be split and executed in parallel by MCP workers.
- The user wants commit message guidance, but will perform final git/PR actions manually.

## Inputs Required
- Task description or implementation plan.
- Repository root path.
- Branch slug candidate derived from the task.
- MCP prerequisites:
  - `multi-agent-mcp` installed
  - `tmux` installed

Optional flags:
- `--plan`: first produce/refresh a plan in Plan Mode, then execute.
- `--help`: explain usage only.

Environment:
```bash
MCP_MODEL_PROFILE_ACTIVE=performance
```
Allowed values: `standard`, `performance`.

## Step-by-Step Workflow

### Phase 1: Setup and Admin launch
1. Create branch:
```bash
git fetch origin main
git checkout main
git pull origin main
git checkout -b feature/{slug}
git push -u origin feature/{slug}
```
2. Create owner agent and store `{owner_id}`:
```text
owner_result = mcp__multi-agent-mcp__create_agent(role="owner", working_dir="{repo_root}")
```
3. Fetch owner role guide before any owner action (mandatory):
```text
mcp__multi-agent-mcp__get_role_guide(role="owner", caller_agent_id="{owner_id}")
```
4. Initialize workspace with `session_id={slug}`:
```text
mcp__multi-agent-mcp__init_tmux_workspace(
  working_dir="{repo_root}",
  open_terminal=true,
  auto_setup_gtr=true,
  session_id="{slug}",
  caller_agent_id="{owner_id}"
)
```
5. Create admin agent and store `{admin_id}`:
```text
admin_result = mcp__multi-agent-mcp__create_agent(
  role="admin",
  working_dir="{repo_root}",
  caller_agent_id="{owner_id}"
)
```
6. Send plan/task to admin:
```text
mcp__multi-agent-mcp__send_task(
  agent_id="{admin_id}",
  task_content="{plan_or_task}",
  session_id="{slug}",
  branch_name="feature/{slug}",
  caller_agent_id="{owner_id}"
)
```
7. Wait for completion notification and periodically check status:
```text
mcp__multi-agent-mcp__get_dashboard_summary(caller_agent_id="{owner_id}")
mcp__multi-agent-mcp__read_messages(agent_id="{owner_id}", caller_agent_id="{owner_id}")
```

### Phase 2-4: Autonomous Admin/Worker execution
- MCP controls execution.
- Owner remains idle except status checks.

### Phase 5: Review, approval, cleanup
0. Confirm admin completion message:
```text
mcp__multi-agent-mcp__read_messages(agent_id="{owner_id}", caller_agent_id="{owner_id}")
```
1. Sync integration branch:
```bash
git checkout feature/{slug}
git pull origin feature/{slug}
```
2. Show change summary to user:
```bash
git diff main...feature/{slug} --stat
git log main..feature/{slug} --oneline
```
3. Ask for explicit user decision via `request_user_input` (or direct question if unavailable):
- Approve
- Request fixes
- Hold
4. If approved, notify admin:
```text
mcp__multi-agent-mcp__send_message(
  sender_id="{owner_id}",
  receiver_id="{admin_id}",
  message_type="task_approved",
  content="User approved implementation.",
  caller_agent_id="{owner_id}"
)
```
5. If fixes requested, send request and return to autonomous phase:
```text
mcp__multi-agent-mcp__send_message(
  sender_id="{owner_id}",
  receiver_id="{admin_id}",
  message_type="request",
  content="Fix request: {user_feedback}",
  caller_agent_id="{owner_id}"
)
```
6. Cleanup when all tasks complete:
```text
mcp__multi-agent-mcp__check_all_tasks_completed(caller_agent_id="{owner_id}")
mcp__multi-agent-mcp__cleanup_on_completion(caller_agent_id="{owner_id}")
```
7. Security check:
```bash
git status
```
Warn if sensitive files (for example `.env*`, `*.pem`, `credentials.json`) are staged.
8. Output recommended commit message only. Do not auto-commit/push/create PR in this skill.

## Output Contract
The final response must include:
- Implementation completion summary.
- Recommended Conventional Commit message.
- Manual next steps:
```text
1. git add .
2. git commit -m "{message}"
3. git push origin feature/{slug}
4. optionally gh pr create
```

## Failure/Recovery
- Missing `caller_agent_id`: stop and recreate/fetch correct owner/admin IDs.
- MCP/tmux not available: report blocker and request install/repair before retry.
- Admin reports partial failure: send targeted fix request and re-enter Phase 2-4.
- User selects hold: keep state, do not cleanup until explicit continuation.

## Examples
- "multi-flowでこのリファクタを並列実行して"
- "Issueなしでマルチエージェント実装だけ進めて"
- "軽量並列フローで、最後はコミット文だけ出して"

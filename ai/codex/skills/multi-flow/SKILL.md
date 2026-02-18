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
  - Build a concise English slug from the task.
  - If slug generation fails, use `no-git-task`.
- MCP prerequisites:
  - `multi-agent-mcp` installed
  - `tmux` installed

Optional flags:
- `--plan`: first produce/refresh a plan in Plan Mode, then execute.
- `--no-git`: force no-git mode and skip git branch workflow.
- `--help`: explain usage only.

Environment:
```bash
MCP_MODEL_PROFILE_ACTIVE=performance
```
Allowed values: `standard`, `performance`.

## Execution Mode (Required)
Resolve execution mode in this order:

1. `--no-git` is specified: always use `no-git` mode.
2. `--no-git` is not specified and `git rev-parse --is-inside-work-tree` succeeds: use `git` mode.
3. `git rev-parse` fails: ask the user and branch behavior:
   - Continue in `no-git` mode, or
   - Stop and ask user to rerun in a git-managed repository.

Detection command:
```bash
git rev-parse --is-inside-work-tree >/dev/null 2>&1
```

Important:
- Do not auto-select no-git when git detection fails.
- Require explicit user confirmation before continuing in no-git mode in this case.

## Step-by-Step Workflow

Mode summary:

```text
git mode:
Phase 1: Owner -> Branch setup -> MCP init -> Admin launch -> Send plan/task
Phase 2-4: Admin/Workers run autonomously via MCP
Phase 5: Owner -> Review -> Approve/fix loop -> Cleanup -> Commit message output

no-git mode:
Phase 1: Owner -> MCP init(enable_git=false) -> Admin launch -> Send plan/task
Phase 2-4: Admin/Workers run autonomously via MCP
Phase 5: Owner -> Review(Admin report) -> Approve/fix loop -> Cleanup -> Summary output
```

### Phase 1: Setup and Admin launch
1. Resolve execution mode:
```bash
if [ "{no_git_flag}" = "true" ]; then
  FLOW_MODE="no-git"
elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  FLOW_MODE="git"
else
  FLOW_MODE="unknown"
fi
```
If `FLOW_MODE="unknown"`, ask the user:
- Continue in `no-git` mode, or
- Stop and rerun in a git repository.

2. Resolve `slug`:
```text
slug = {task_slug}
if slug is empty: slug = "no-git-task"
```

3. Create branch only in `git` mode:
```bash
DEFAULT_BRANCH="$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || true)"
if [ -z "$DEFAULT_BRANCH" ]; then
  echo "gh で default branch を取得できません。gh 認証/リポジトリ設定を確認してください。" >&2
  exit 1
fi

git fetch origin "$DEFAULT_BRANCH"
git checkout "$DEFAULT_BRANCH"
git pull origin "$DEFAULT_BRANCH"
git checkout -b feature/{slug}
git push -u origin feature/{slug}
```
Skip this step in `no-git` mode.

4. Create owner agent and store `{owner_id}`:
```text
owner_result = mcp__multi-agent-mcp__create_agent(role="owner", working_dir="{repo_root}")
```
5. Fetch owner role guide before any owner action (mandatory):
```text
mcp__multi-agent-mcp__get_role_guide(role="owner", caller_agent_id="{owner_id}")
```
6. Initialize workspace:

git mode:
```text
mcp__multi-agent-mcp__init_tmux_workspace(
  working_dir="{repo_root}",
  open_terminal=true,
  auto_setup_gtr=true,
  session_id="{slug}",
  caller_agent_id="{owner_id}"
)
```

no-git mode:
```text
mcp__multi-agent-mcp__init_tmux_workspace(
  working_dir="{repo_root}",
  open_terminal=true,
  auto_setup_gtr=true,
  session_id="{slug}",
  enable_git=false,
  caller_agent_id="{owner_id}"
)
```
In no-git mode, `enable_git=false` is mandatory.

7. Create admin agent and store `{admin_id}`:
```text
admin_result = mcp__multi-agent-mcp__create_agent(
  role="admin",
  working_dir="{repo_root}",
  caller_agent_id="{owner_id}"
)
```

8. Send plan/task to admin:

git mode:
```text
mcp__multi-agent-mcp__send_task(
  agent_id="{admin_id}",
  task_content="{plan_or_task}",
  session_id="{slug}",
  branch_name="feature/{slug}",
  caller_agent_id="{owner_id}"
)
```

no-git mode:
```text
mcp__multi-agent-mcp__send_task(
  agent_id="{admin_id}",
  task_content="{plan_or_task}",
  session_id="{slug}",
  caller_agent_id="{owner_id}"
)
```
In no-git mode, do not pass `branch_name`.

9. Wait for completion notification and periodically check status:
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

1. Review and show implementation details:

git mode:
```bash
git checkout feature/{slug}
git pull origin feature/{slug}
DEFAULT_BRANCH="$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || true)"
if [ -z "$DEFAULT_BRANCH" ]; then
  echo "gh で default branch を取得できません。gh 認証/リポジトリ設定を確認してください。" >&2
  exit 1
fi

git diff "$DEFAULT_BRANCH"...feature/{slug} --stat
git log "$DEFAULT_BRANCH"..feature/{slug} --oneline
```

no-git mode:
```text
mcp__multi-agent-mcp__get_dashboard_summary(caller_agent_id="{owner_id}")
mcp__multi-agent-mcp__read_messages(
  agent_id="{owner_id}",
  caller_agent_id="{owner_id}",
  unread_only=false,
  mark_as_read=false
)
```
Show to user:
- Admin implementation summary
- changed files
- test results
- remaining TODOs

2. Ask for explicit user decision (direct question or `request_user_input` if available):
- Approve
- Request fixes
- Hold

3. If approved, notify admin:
```text
mcp__multi-agent-mcp__send_message(
  sender_id="{owner_id}",
  receiver_id="{admin_id}",
  message_type="task_approved",
  content="User approved implementation.",
  caller_agent_id="{owner_id}"
)
```

4. If fixes requested, send request and return to autonomous phase:
```text
mcp__multi-agent-mcp__send_message(
  sender_id="{owner_id}",
  receiver_id="{admin_id}",
  message_type="request",
  content="Fix request: {user_feedback}",
  caller_agent_id="{owner_id}"
)
```

5. Cleanup when all tasks complete:
```text
mcp__multi-agent-mcp__check_all_tasks_completed(caller_agent_id="{owner_id}")
mcp__multi-agent-mcp__cleanup_on_completion(caller_agent_id="{owner_id}")
```

6. Security check:

git mode:
```bash
git status
```
Warn if sensitive files (for example `.env*`, `*.pem`, `credentials.json`) are staged.

no-git mode:
```bash
find . -maxdepth 3 \( -name ".env*" -o -name "*.pem" -o -name "credentials.json" \)
```
Warn if sensitive files are found.

7. Output completion:
- git mode: output recommended commit message only. Do not auto-commit/push/create PR in this skill.
- no-git mode: output implementation summary only, without git-specific next steps.

## Output Contract
The final response must include:
- Mode (`git` or `no-git`) used and why.

If `git` mode:
- Implementation completion summary.
- Recommended Conventional Commit message.
- Manual next steps:
```text
1. git add .
2. git commit -m "{message}"
3. git push origin feature/{slug}
4. optionally gh pr create
```

If `no-git` mode:
```text
## Implementation Complete (no-git mode)

### Summary
- Changed files: {admin_report_files}
- Test results: {admin_report_tests}
- Remaining TODOs: {admin_report_todos}

### Next steps
- Apply or deploy changes according to the user's environment workflow.
```

## Failure/Recovery
- Missing `caller_agent_id`: stop and recreate/fetch correct owner/admin IDs.
- MCP/tmux not available: report blocker and request install/repair before retry.
- `gh` default branch resolution fails: stop and ask user to fix `gh` auth/repository context.
- Git detection failed and user decision is not captured: stop and ask user to choose no-git continue or stop.
- In no-git mode, never pass `branch_name` to `send_task`.
- Admin reports partial failure: send targeted fix request and re-enter Phase 2-4.
- User selects hold: keep state, do not cleanup until explicit continuation.

## Examples
- "multi-flowでこのリファクタを並列実行して"
- "Issueなしでマルチエージェント実装だけ進めて"
- "軽量並列フローで、最後はコミット文だけ出して"
- "multi-flow --no-git で並列実装して"
- "git 管理外ディレクトリだけど、確認して no-git で続行して"

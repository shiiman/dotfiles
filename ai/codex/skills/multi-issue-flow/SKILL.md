---
name: multi-issue-flow
description: Run the multi-agent MCP flow from Issue creation through PR creation with parallel worker execution. Triggers on "multi-issue-flow", "マルチ Issue フロー", and similar requests.
---

# Multi Issue Flow (Codex)

## Purpose
Use `multi-issue-flow` when the user wants end-to-end issue-driven parallel development: Issue creation, branching, MCP parallel execution, review, commit, push, and PR creation.

## When to Use
- User explicitly asks for `multi-issue-flow` or equivalent terms.
- Work should start from a tracked GitHub Issue.
- User expects PR generation at the end of the flow.

## Inputs Required
- Task objective and scope.
- Issue title/body (or enough detail to generate them).
- Repository root path.
- Issue labels (optional).
- MCP prerequisites:
  - `multi-agent-mcp` installed
  - `tmux` installed
- GitHub CLI auth (`gh auth status` should pass).

Optional flags:
- `--plan`: first produce/refresh a plan in Plan Mode, then execute.
- `--help`: explain usage only.

Environment:
```bash
MCP_MODEL_PROFILE_ACTIVE=performance
```
Allowed values: `standard`, `performance`.

## Step-by-Step Workflow

### Phase 1: Issue creation, setup, admin launch
1. Create GitHub Issue:
```bash
gh repo view --json owner,name
gh issue create --title "{title}" --body "{body}" --label "{label}"
```
Issue body template:
```markdown
## 概要
{目的・背景}

## タスク一覧
- [ ] Task 1: {subtask}
- [ ] Task 2: {subtask}

## 完了条件
- 全Task完了
- テスト通過
```
2. Create branch from main using issue number:
```bash
git fetch origin main
git checkout main
git pull origin main
git checkout -b feature/{issue_number}
git push -u origin feature/{issue_number}
```
3. Create owner agent and store `{owner_id}`:
```text
owner_result = mcp__multi-agent-mcp__create_agent(role="owner", working_dir="{repo_root}")
```
4. Fetch owner role guide (mandatory):
```text
mcp__multi-agent-mcp__get_role_guide(role="owner", caller_agent_id="{owner_id}")
```
5. Initialize MCP workspace with `session_id={issue_number}`:
```text
mcp__multi-agent-mcp__init_tmux_workspace(
  working_dir="{repo_root}",
  open_terminal=true,
  auto_setup_gtr=true,
  session_id="{issue_number}",
  caller_agent_id="{owner_id}"
)
```
6. Create admin agent and store `{admin_id}`:
```text
admin_result = mcp__multi-agent-mcp__create_agent(
  role="admin",
  working_dir="{repo_root}",
  caller_agent_id="{owner_id}"
)
```
7. Send plan/task to admin:
```text
mcp__multi-agent-mcp__send_task(
  agent_id="{admin_id}",
  task_content="{plan_or_task}",
  session_id="{issue_number}",
  branch_name="feature/{issue_number}",
  caller_agent_id="{owner_id}"
)
```
8. Wait for completion notification and poll:
```text
mcp__multi-agent-mcp__get_dashboard_summary(caller_agent_id="{owner_id}")
mcp__multi-agent-mcp__read_messages(agent_id="{owner_id}", caller_agent_id="{owner_id}")
```

### Phase 2-4: Autonomous Admin/Worker execution
- MCP controls execution.
- Owner waits except for status checks.

### Phase 5: Review, approval, finalize, PR
0. Confirm admin completion message:
```text
mcp__multi-agent-mcp__read_messages(agent_id="{owner_id}", caller_agent_id="{owner_id}")
```
1. Sync feature branch:
```bash
git checkout feature/{issue_number}
git pull origin feature/{issue_number}
```
2. Show change summary:
```bash
git diff main...feature/{issue_number} --stat
git log main..feature/{issue_number} --oneline
```
3. Ask for user decision via `request_user_input` (or direct question if unavailable):
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
6. Cleanup after completion:
```text
mcp__multi-agent-mcp__check_all_tasks_completed(caller_agent_id="{owner_id}")
mcp__multi-agent-mcp__cleanup_on_completion(caller_agent_id="{owner_id}")
```
7. Security check:
```bash
git status
```
Warn if sensitive files are staged.
8. Mark Issue checklist items complete.
9. Commit and push:
```bash
git add .
git commit -m "{commit_message}"
git push origin feature/{issue_number}
```
10. Create PR:
```bash
gh pr create --title "{pr_title}" --body "{pr_body}"
```
PR body template:
```markdown
## 概要
{変更内容}

## 並列実行サマリー
| Worker | Task | 状態 |
|--------|------|------|
| Worker 1 | Task 1 | Completed |

## 関連 Issue
Closes #{issue_number}

## テスト計画
- [ ] {test_item}
```
11. Report completion including Issue/PR identifiers and URL.

## Output Contract
The final response must include:
- Issue number/title.
- PR number/title/URL.
- Parallel execution summary.
- Merge note: merging PR will auto-close linked issue.

## Failure/Recovery
- `gh` auth/repo failure: stop and request GitHub authentication/context fix.
- Missing `caller_agent_id`: stop and recover IDs before next MCP call.
- Admin partial failure: send targeted fix request and loop back.
- PR creation failure: provide exact failing command/output and keep branch pushed.
- User selects hold: keep state, do not cleanup/finalize until continuation.

## Examples
- "multi-issue-flowでこの要件をIssueからPRまで進めて"
- "マルチ Issue フローで並列実装してPR作って"
- "Issue駆動で複数Workerに振って最後まで完了して"

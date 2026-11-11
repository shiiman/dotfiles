---
name: workflow-multi
description: Implement a requested task with multiple agents, including only authorized commit, Issue, push, and PR steps. Use for workflow-multi and explicit parallel multi-agent development requests. Default to implementation and validation without optional approval questions.
---

# Multi Flow

Codex の multi_agent 機能（Owner/Admin/Worker）で並列実装する開発フロー。

フラグは不要。タスクを伝えれば、git の状態・発話内容から実行条件を自動判断し、曖昧な点だけ確認する。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
workflow-multi - マルチエージェント開発フロー

概要:
  Codex の multi_agent 機能（Owner/Admin/Worker）で並列実装する。
  実装条件（Issue/PR・計画書・ブランチ・git）はフラグ不要で自動判断し、
  曖昧な点だけ確認する。

使用方法:
  workflow-multi [タスク説明]
  workflow-multi --help

オプション:
  --help  このヘルプを表示

例:
  workflow-multi                            # 既存計画書から並列実装（あれば）
  workflow-multi "API を並列リファクタ"      # タスク説明から並列実装
  workflow-multi "認証を実装して PR まで"    # 並列実装・コミット・push・PR 作成
  workflow-multi --help                     # ヘルプを表示

指定の伝え方（フラグの代わり）:
  - 「計画を立ててから」  → 計画書を作成してから実装
  - 「ブランチで」        → worktree ではなくブランチを作成
  - 「PR まで」           → コミット・通常の push・PR 作成まで実施
  - 「Issue と PR まで」   → Issue 作成も含めて実施
  - 「コミットだけ」      → 検証後にコミットし、push・Issue・PR は作成しない
```

## 前提条件

- Codex の multi_agent 機能が利用可能（**必須**）
- tmux がインストール済み（**必須**）
- `gh` コマンドが利用可能
- `gh auth status` が成功する（GitHub CLI 認証済み）

## ⚠️ caller_agent_id について（重要）

**全てのツールには `caller_agent_id` パラメータが必須です。**

- `create_agent()` の戻り値から自分の ID を取得し、`{owner_id}` として保存
- 以降の全ツール呼び出しで `caller_agent_id="{owner_id}"` を指定

## 起動時の自動判断（フラグの代わり）

ユーザーにフラグを入力させない。以下を順に決定する。**発話・タスク説明に明示があればそれを最優先**し、明示がなければ自動判断、それでも曖昧な項目だけ後述の手順で確認する。

| 項目              | 既定       | 判断ルール                                                                                |
| ----------------- | ---------- | ----------------------------------------------------------------------------------------- |
| git / no-git      | 自動       | `git rev-parse --is-inside-work-tree` 成功なら git。失敗なら no-git（ブランチ作成を省略） |
| worktree / branch | worktree   | 「ブランチで」「worktree なし」等の発話があれば branch                                    |
| 計画書の扱い      | 後述の判定 | 「計画を立てて」「plan で」→ 計画書作成。タスク説明あり → 直接。なし → 既存計画書を探索   |

### Authorized completion scope

Determine each action independently from the current request and existing authorization:

- Implementation-only request: implement, review, and validate; finish without asking whether to commit or create an Issue/PR.
- Commit-only request: perform checks and commit the intended changes; do not push or create an Issue/PR.
- PR creation request: complete the required implementation, validation, intended commits, and normal feature-branch push before creating the PR. Do not create a separate Issue unless requested or required by an authorized workflow.
- Issue creation request: create only the requested Issue and any explicitly requested follow-up actions. Link a verified existing Issue when appropriate.
- Explicit restrictions such as "do not push" take precedence. Report a concrete blocker rather than silently expanding scope.

Do not require `--no-confirm`, plan approval, or a second completion approval for already authorized actions. The later "Issue/PR" finishing section applies only to the individually authorized actions; skip unrequested steps. Recheck authorization for material scope changes, destructive operations, or other high-impact actions.

### git の状態判定

```bash
git rev-parse --is-inside-work-tree >/dev/null 2>&1
```

- 成功 → git モード（ブランチ/worktree を作成、`init_tmux_workspace` は通常設定）
- 失敗 → no-git モード（ブランチ作成を省略、`init_tmux_workspace` に `enable_git=false` を渡す）

### 計画書の扱いの判定

1. 「計画を立ててから」等の依頼がある → **Plan**: write the requested plan to `.codex/plans/`. If implementation is also requested, proceed after explaining it; wait only when the user explicitly requests plan approval or a material decision remains unresolved
2. タスク説明がある → **直接実行**: タスク説明をそのまま実装の指針にする
3. タスク説明なし → **既存計画書**: 最新の計画書を読み込む（`ls -t ~/.codex/plans/*.md | head -1`）。見つからなければタスク説明を促して終了

### session_id / slug ルール

- When a verified related Issue exists, use its number as `session_id`.
- Otherwise derive `session_id` from a concise English task slug, whether or not PR creation is requested.

## Phase 1: セットアップ + Admin 起動

### Step A: Create an Issue only when authorized

`github-issue-create` スキルのワークフローに従い、`--no-confirm` オプションで Issue を作成する。本文は「## 概要 / ## タスク一覧（チェックボックス）/ ## 完了条件」で構成。作成された Issue 番号を `session_id` と後続に使う。

### ステップ 1: ブランチ / worktree 作成

git モードのみ実施（no-git はスキップ）。

- worktree（既定）: `github-worktree-create` スキルのワークフローに従う
- ブランチ: `github-branch-create` スキルのワークフローに従う
- Pass an Issue number only when a verified related Issue exists; otherwise use a task-derived branch name.

> **Note**: `github-worktree-create` は worktree 作成後に `mise trust` を自動実行するため、追加の対応は不要。

### ステップ 2: Owner エージェント作成

```text
owner_result = create_agent(role="owner", working_dir="パス")
# owner_result["agent"]["id"] を {owner_id} として保存
```

### ステップ 3: Owner の役割を取得（🔴 必須）

```text
get_role_guide(role="owner", caller_agent_id="{owner_id}")
```

### ステップ 4: ワークスペース初期化

```text
init_tmux_workspace(
    working_dir="プロジェクトのルートパス",
    open_terminal=true,
    auto_setup_gtr=true,
    session_id="{session_id}",
    caller_agent_id="{owner_id}"
    # no-git モードのときのみ、以下を追加:
    # enable_git=false,
)
```

**no-git モードでは `enable_git=false` を必ず追加で渡す（git モードでは省略してよい）。**

### ステップ 5: Admin エージェント作成

```text
admin_result = create_agent(
    role="admin", working_dir="パス", caller_agent_id="{owner_id}"
)
# admin_result["agent"]["id"] を {admin_id} として保存
```

### ステップ 6: Admin に計画書を送信

```text
send_task(
    agent_id="{admin_id}",
    task_content="計画書またはタスク説明",
    session_id="{session_id}",
    branch_name="feature/{session_id}",  # git モードのみ。no-git では渡さない
    caller_agent_id="{owner_id}"
)
```

**no-git モードでは `branch_name` を渡さない。**

### ステップ 7: Admin の完了を待機

Monitor completion with the available agent status or wait tools and proceed to Phase 5 when work completes. Do not require the user to ask for a status check before continuing.

```text
get_dashboard_summary(caller_agent_id="{owner_id}")
read_messages(agent_id="{owner_id}", caller_agent_id="{owner_id}")
```

## Phase 2-4: Admin/Worker の自律実行

**自動制御。Owner は待機のみ。**

## Phase 5: Verify results and continue

### ステップ 1: 完了報告と変更内容を表示

```text
read_messages(agent_id="{owner_id}", caller_agent_id="{owner_id}")
```

git モード:

```bash
git status --short --branch
git diff
git diff --cached
```

no-git モード: Admin の最終報告（実装サマリー・変更ファイル・テスト結果・残課題）を表示。

### Step 2: Verify results and authorization

Inspect the actual diff and validation results, and resolve actionable findings within the task. Continue automatically when implementation and subsequent actions are already authorized. Ask only about material unresolved decisions or unapproved impact. Do not wait for a generic "OK".

Before cleanup, inspect what the cleanup tool removes. Clean up only agents and temporary resources owned by this task; preserve worktrees, changes, and other useful user work. If the tool cannot guarantee that scope, leave the resources intact and report them.

### After verification

1. Notify Admin that verification is complete and authorized follow-up can proceed:

   ```text
   send_message(
       sender_id="{owner_id}", receiver_id="{admin_id}",
       message_type="task_approved", content="検証完了。許可済みの範囲で後続処理へ進みます。",
       caller_agent_id="{owner_id}"
   )
   ```

2. クリーンアップ:

   ```text
   check_all_tasks_completed(caller_agent_id="{owner_id}")
   cleanup_on_completion(caller_agent_id="{owner_id}")
   ```

3. セキュリティチェック: 機密ファイル（`.env*` / `*.pem` / `credentials.json`）を検出したら警告

   ```bash
   git status   # git モード
   find . -maxdepth 3 \( -name ".env*" -o -name "*.pem" -o -name "credentials.json" \)  # no-git モード
   ```

4. 「仕上げ」へ進む

## 仕上げ

### Authorized completion actions

1. Update only verified completed checkboxes on an authorized Issue; never mark unfinished tasks complete.
2. コミット: `git-add-commit` スキルのワークフローに従い、`--no-confirm` オプションでコミットする
3. When push or PR creation is authorized, verify the remote, destination, and outgoing commits, then execute a normal push for the actual feature branch. Never force-push, push to the default branch, or publish unrelated work under this authorization.
4. PR 作成: `github-pr-create` スキルのワークフローに従い、`--no-confirm` オプションで PR を作成する。Use a Japanese summary, parallel task results, and validation results. Include `Closes #N` only for a verified related Issue; omit the Issue section otherwise
5. Report actual changes, checks, and completed actions. Include Issue or PR numbers/URLs only when they exist; never claim an unperformed action completed.

### Issue/PR 連携なし（軽量）

For implementation-only requests, report changes and validation without committing, pushing, or creating an Issue/PR. For an explicit commit-only request, validate and commit the intended changes, then report the commit. Do not ask an optional follow-up question.

```text
## 実装完了

### 作成されたブランチ / worktree（git モード時のみ）
- {ブランチ名} / パス: {worktree のパス}（worktree モード時のみ）

### 推奨コミットメッセージ
{Conventional Commits message following repository and global instructions}

### 検証結果
{実行したチェック・結果・残課題}

### worktree クリーンアップ（worktree モード時のみ）
PR マージ後、`/git-worktree` で gtr rm または gtr clean を実行してください。
```

## 重要な注意事項

- ✅ ユーザーにフラグを入力させない（git・worktree/branch・計画書・Issue/PR を自動判断、曖昧なら確認）
- ✅ 全ツールに `caller_agent_id` を渡す
- ✅ no-git モードでは `enable_git=false` と `branch_name` 省略を徹底
- Verify cleanup scope and preserve useful work; do not add a generic completion approval gate.
- Follow repository commit conventions and global instructions; do not invent unsupported configuration keys.
- Execute each external or Git completion action only within its independently authorized scope.

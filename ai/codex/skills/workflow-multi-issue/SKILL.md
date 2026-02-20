---
name: workflow-multi-issue
description: マルチエージェントで Issue から PR まで並列実行する開発フロー。「マルチ Issue フロー」「workflow-multi-issue」「並列 Issue 開発」「マルチエージェント Issue」「複数人で Issue」「並列 Issue フロー」「マルチフロー Issue」などで起動。複数 Worker でタスクを並列実行。
---

# Multi Issue Flow

マルチエージェントで Issue から PR まで並列実行する開発フロー。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
/workflow-multi-issue - マルチエージェント Issue 開発フロー

概要:
  マルチエージェントで Issue 作成から PR 作成まで並列実行する。
  Issue 作成 → 初期化 → Admin/Worker 並列実行 → コミット → PR 作成。

使用方法:
  /workflow-multi-issue [タスク説明] [オプション]

オプション:
  --plan  計画書を新規作成してから実行
  --help  このヘルプを表示

例:
  /workflow-multi-issue                        # 既存計画書から実行
  /workflow-multi-issue --plan                 # 計画書を作成してから実行
  /workflow-multi-issue "認証機能を並列実装"    # タスク説明から直接実行
```

## 前提条件

- Codex の multi_agent 機能が利用可能（**必須**）
- tmux がインストール済み（**必須**）

## 実行フロー

```
Phase 1: Owner  → Issue 作成 → ブランチ作成 → 初期化 → Admin 起動 → 計画書送信
Phase 2-4: Admin/Worker が自律実行（自動制御）
Phase 5: Owner  → 結果確認 → ユーザー承認 → クリーンアップ → コミット → PR 作成
```

## ⚠️ caller_agent_id について（重要）

**全てのツールには `caller_agent_id` パラメータが必須です。**

- `create_agent()` の戻り値から自分の ID を取得
- 以降の全ツール呼び出しで `caller_agent_id="{owner_id}"` を指定

---

## Phase 1: Issue 作成 + セットアップ + Admin 起動

### ステップ 1: Issue 作成

`github-issue-create` スキルのワークフローに従い、`--no-confirm` オプションで Issue を作成する。

**Issue 本文フォーマット**:

```markdown
## 概要

{タスクの目的・背景}

## タスク一覧

- [ ] Task 1: {サブタスク1}
- [ ] Task 2: {サブタスク2}
      ...

## 完了条件

- 全てのTaskが完了していること
- テストが通過していること
```

### ステップ 2: ベースブランチ作成

`github-branch-create` スキルのワークフローに従い、作成した Issue の番号でブランチを作成する。

ユーザーがベースブランチを明示した場合は、そちらを優先する。

### ステップ 3: Owner エージェント作成

Codex の multi_agent 機能を使用して Owner エージェントを作成する。

```
owner_result = create_agent(role="owner", working_dir="パス")
# owner_result["agent"]["id"] を {owner_id} として保存
```

### ステップ 4: Owner の役割を取得（🔴 必須）

**Owner として行動する前に、必ずロールガイドを取得してください。**

```
get_role_guide(role="owner", caller_agent_id="{owner_id}")
```

このガイドには Owner の責務、禁止事項、ワークフローが記載されています。

### ステップ 5: ワークスペース初期化

```
init_tmux_workspace(
    working_dir="プロジェクトのルートパス",
    open_terminal=true,
    auto_setup_gtr=true,
    session_id="{issue番号}",
    caller_agent_id="{owner_id}"
)
```

**重要**: `session_id` には Issue 番号を指定。これによりセッションデータが `{issue番号}/` 配下に配置される。

### ステップ 6: Admin エージェント作成

```
admin_result = create_agent(
    role="admin",
    working_dir="パス",
    caller_agent_id="{owner_id}"
)
# admin_result["agent"]["id"] を {admin_id} として保存
```

### ステップ 7: Admin に計画書を送信

```
send_task(
    agent_id="{admin_id}",
    task_content="計画書またはタスク説明",
    session_id="Issue 番号",
    branch_name="feature/{issue番号}",
    caller_agent_id="{owner_id}"
)
```

### ステップ 8: Admin の完了を待機

**待機中**: macOS 通知で Admin からの完了報告が届きます。ユーザーから「Admin から完了通知来てるか確認して」と指示されたら Phase 5 へ進みます。

```
get_dashboard_summary(caller_agent_id="{owner_id}")
read_messages(agent_id="{owner_id}", caller_agent_id="{owner_id}")
```

---

## Phase 2-4: Admin/Worker の自律実行

**自動制御。Owner は待機のみ。**

---

## Phase 5: 結果確認 + ユーザー承認 + PR 作成

### ステップ 0: Admin からの完了報告を確認

macOS 通知が届いたら、ユーザーから「Admin から完了通知来てるか確認して」と指示されます。

```
read_messages(
    agent_id="{owner_id}",
    caller_agent_id="{owner_id}"
)
```

### ステップ 1: 変更内容をユーザーに表示

```bash
git status --short --branch
git diff
git diff --cached
```

変更内容、品質チェック結果（Admin からの報告）をユーザーに表示。

### ステップ 2: ユーザー確認（🔴 必須）

**⚠️ クリーンアップの前に必ずユーザー確認を行う**

ユーザーに確認を取る:

```
実装内容を確認しました。承認しますか？

選択肢:
- OK（承認）: クリーンアップして PR 作成へ進む
- NG（修正依頼）: 修正内容を指定して Admin に再指示
- 保留: 手動で確認してから判断
```

---

### OK（承認）の場合

#### ステップ 3: Admin に承認通知を送信

```
send_message(
    sender_id="{owner_id}",
    receiver_id="{admin_id}",
    message_type="task_approved",
    content="ユーザー確認完了。実装を承認します。",
    caller_agent_id="{owner_id}"
)
```

---

### NG（修正依頼）の場合

1. 修正内容をユーザーに確認
2. Admin に再指示を送信

```
send_message(
    sender_id="{owner_id}",
    receiver_id="{admin_id}",
    message_type="request",
    content="修正依頼: {ユーザーからの修正内容}",
    caller_agent_id="{owner_id}"
)
```

3. Phase 2-4 に戻り、Admin が修正タスクを実行

---

#### ステップ 4: クリーンアップ

```
check_all_tasks_completed(caller_agent_id="{owner_id}")
cleanup_on_completion(caller_agent_id="{owner_id}")
```

#### ステップ 5: セキュリティチェック

```bash
git status  # .env*, *.pem, credentials.json を検出したら警告
```

#### ステップ 6: Issue チェックボックス更新

Issue の全てのチェックボックスを完了状態に更新。

#### ステップ 7: コミット

`git-add-commit` スキルのワークフローに従い、`--no-confirm` オプションでコミットする。

#### ステップ 8: プッシュ案内

以下のコマンドをユーザーに提示する（自動実行しない）:

```bash
git push -u origin feature/{issue番号}
```

#### ステップ 9: PR 作成

`github-pr-create` スキルのワークフローに従い、`--no-confirm` オプションで PR を作成する。

**PR 本文**:

```markdown
## 概要

{変更内容の説明}

## 並列実行サマリー

| Worker   | Task   | 状態    |
| -------- | ------ | ------- |
| Worker 1 | Task 1 | ✅ 完了 |

...

## 関連 Issue

Closes #{issue番号}

## テスト計画

- [ ] {テスト項目}
```

#### ステップ 10: 完了報告

```
## 開発フロー完了

### 作成された Issue
- #{issue番号}: {タイトル}

### 作成された PR
- PR #{pr番号}: {タイトル}
- URL: {pr_url}

PR がマージされると Issue #{issue番号} は自動的にクローズされます。
```

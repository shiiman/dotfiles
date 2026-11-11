---
name: github-issue-create
description: GitHub Issue を作成する。タスクは Issue 本文内でチェックボックスに分割。「Issue 作成」「Issue を作って」「タスクを Issue に」「Issue 追加」「チケット作成」「Issue を切る」「タスクを分割して Issue」などで起動。「ブランチも」「worktree も」と伝えれば作成後にブランチ/worktree も用意する。
---

# Create Issue

GitHub Issue を作成します。タスクは Issue 本文内でチェックボックスに分割します。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
/github-issue-create - Create Issue

概要:
  GitHub Issue を作成します。
  タスクは Issue 本文内でチェックボックスに分割します。
  「ブランチも」「worktree も」と伝えれば作成後にブランチ/worktree も用意します。

使用方法:
  /github-issue-create [タスク説明]

オプション:
  --help  このヘルプを表示

後続作成の伝え方:
  「ブランチも作って」    → Issue 作成後にブランチを作成
  「worktree も」         → Issue 作成後に worktree を作成（gtr 使用）
  指定なし                → Issue 作成のみで終了

例:
  /github-issue-create                    # Issue を作成
  「Issue を作ってブランチも切って」        # Issue 作成後にブランチも作成
  「Issue を作って worktree も用意して」    # Issue 作成後に worktree も作成

内部呼び出し用:
  --no-confirm  Compatibility flag for already authorized workflow calls
```

## Authorization

Use the global authorization policy and the current request to determine scope. An explicit request for this skill's action is sufficient authorization; do not ask again just to approve generated wording or require `--no-confirm`. The flag remains compatible with authorized workflow callers, but never grants permission by itself. Preserve security checks and ask only for missing authorization, a material scope change, or a concrete risk outside the approved scope.

## ワークフロー

### 1. タスクの確認

Use the task description and conversation first. Ask for the task summary only if the intended Issue cannot be determined from available context.

### 2. タスクの分割

タスクを Issue 本文内のチェックボックスに分割:

- 1 タスク = 具体的なアクション（「〜を追加」「〜を修正」「〜を削除」）
- 依存関係がある場合は順番に並べる
- テストやドキュメント更新も個別タスクとして記載

### 3. Prepare Issue content

Prepare the title, labels, task checkboxes, and completion criteria from the request. An explicit Issue creation request authorizes publishing this content without a second wording approval. Ask only for missing material information or unapproved scope; `--no-confirm` alone is not authorization.

### 4. Issue 作成

Once creation is authorized and the content is validated, create the Issue with `gh issue create`.

**コマンドテンプレート**:

```bash
gh issue create \
  --title "[{scope}] {title}" \
  --body "## 概要

{description}

## タスク

- [ ] {task1}
- [ ] {task2}
- [ ] {task3}

## 完了条件

- {condition1}
- {condition2}
" \
  --label "{labels}"
```

### 5. 結果報告

作成した Issue の結果を報告:

```
Issue を作成しました:

- 番号: #{number}
- タイトル: [{scope}] {title}
- ラベル: {labels}
- URL: {issue_url}
```

### 6. ブランチもしくは worktree 作成

引数・発話から後続作成の要否を判定する。

**「ブランチも」と判定した場合**:

作成した Issue の番号で `github-branch-create` スキルのワークフローに従いブランチを自動作成する。

**「worktree も」と判定した場合**:

作成した Issue の番号で `github-worktree-create` スキルのワークフローに従い worktree を自動作成する。

**When no follow-up creation is requested**:

Finish after reporting the Issue URL. Do not ask whether to create a branch or worktree. When an authorized parent workflow requires one, follow that workflow without an additional question.

## Issue タイトルの形式

`[{scope}] {title}`

- scope: 機能名や対象コンポーネント
- title: 具体的なタスク内容

## ラベルの自動判定

| 内容             | ラベル          |
| ---------------- | --------------- |
| 新機能           | `enhancement`   |
| バグ修正         | `bug`           |
| テスト           | `enhancement`   |
| ドキュメント     | `documentation` |
| リファクタリング | `improvement`   |

## 重要な注意事項

- ✅ タスクは Issue 本文内のチェックボックスで管理
- ✅ 完了条件を明確にする
- ✅ 具体的なアクションを記述
- ❌ 曖昧なタスク記述
- ❌ ブランチと worktree の同時作成はしない（どちらか一方のみ。両方求められた場合は worktree を優先して確認）

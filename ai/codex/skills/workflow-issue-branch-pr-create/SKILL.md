---
name: workflow-issue-branch-pr-create
description: 既存変更から Issue → ブランチ → コミット・プッシュ（コマンド提示）→ PR を作成する Backward フロー。「変更から Issue と PR」「既存変更を PR に」「diff から Issue」「変更を Issue 化」「Backward フロー」などで起動。
---

# Issue Branch PR Create（Backward フロー）

既存の変更内容から Issue → ブランチ → コミット → プッシュ提示 → PR を作成する Backward フロー。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
/workflow-issue-branch-pr-create - 既存変更から Issue・PR を作成する Backward フロー

概要:
  ワーキングツリーの変更やコミット済み未プッシュの変更から
  Issue → ブランチ/worktree → コミット → プッシュ提示 → PR を自動作成する。

使用方法:
  workflow-issue-branch-pr-create [オプション]

オプション:
  --worktree  ブランチの代わりに worktree を作成（既存変更は手動で移動が必要）
  --help      このヘルプを表示

例:
  workflow-issue-branch-pr-create              # 既存変更から Issue・PR を作成（ブランチ）
  workflow-issue-branch-pr-create --worktree   # worktree 作成モードで実行
```

## フロー概要

```
既存変更 → 確認 → Issue 作成 → ブランチ/worktree 作成 → コミット → プッシュ提示 → PR 作成
```

## 状態分岐テーブル

| ブランチ | 変更状態           | Issue      | Branch   | Commit   | Push | PR   |
| -------- | ------------------ | ---------- | -------- | -------- | ---- | ---- |
| default  | 未コミットあり     | 実行       | 実行     | 実行     | 提示 | 実行 |
| default  | コミット済み未push | 実行       | 実行     | スキップ | 提示 | 実行 |
| feature  | 未コミットあり     | 実行       | スキップ | 実行     | 提示 | 実行 |
| feature  | コミット済み未push | 実行       | スキップ | スキップ | 提示 | 実行 |
| any      | 変更なし           | エラー終了 | -        | -        | -    | -    |

## 実行フロー

### ステップ 1: 変更確認

Bash で現在の変更状態を確認する。

```bash
git status
git diff
git diff --cached
```

未プッシュコミットの確認:

```bash
git log @{u}..HEAD --oneline 2>/dev/null || git log origin/$(git rev-parse --abbrev-ref HEAD)..HEAD --oneline 2>/dev/null
```

**判定ロジック**:

1. ステージング済み変更・未ステージング変更・未プッシュコミットのいずれもない場合 → エラー終了:

```
## エラー: 変更がありません

コミット対象の変更が見つかりませんでした。
変更を加えてから再度実行してください。
```

2. デフォルトブランチ（main/master）か feature ブランチかを判定:

```bash
DEFAULT_BRANCH="$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name')"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
```

- `CURRENT_BRANCH` が `DEFAULT_BRANCH` と一致 → デフォルトブランチ上
- それ以外 → feature ブランチ上

3. 未コミット変更があるか、コミット済み未プッシュのみかを判定

### ステップ 2: Issue 作成

github-issue-create スキルのワークフローに従って実行する。変更内容のサマリーを引数に渡す。`--no-confirm` オプション付き。

作成された Issue 番号を記録する。

### ステップ 3: ブランチ / worktree 作成

**デフォルトブランチ上の場合のみ実行**。feature ブランチ上ならスキップ。

**デフォルト（`--worktree` なし）**:

github-branch-create スキルのワークフローに従って、Issue 番号からブランチを作成する。

**`--worktree` 指定時**:

⚠️ worktree は別ディレクトリに作成されるため、既存の未コミット変更の移動が必要です。
以下の手順で変更を移動する:

1. 元ディレクトリで変更を stash する

```bash
git stash push -m "worktree migration: {issue番号}"
```

2. worktree を作成する

github-worktree-create スキルのワークフローに従って、Issue 番号から worktree を作成する。

3. worktree ディレクトリで stash を適用する

```bash
git stash pop
```

**stash pop が失敗した場合（コンフリクト等）**:

- `git stash pop` がコンフリクトした場合、手動でコンフリクトを解消する
- 元の変更は `git stash list` で確認可能（`git stash pop` 失敗時は stash は残る）
- 復旧が困難な場合は `git stash pop --abort` 後、元ディレクトリに戻り `git stash pop` で変更を復元し、`--worktree` なしでやり直す

### ステップ 4: コミット

**未コミット変更がある場合のみ実行**。コミット済みならスキップ。

git-add-commit スキルのワークフローに従って実行する。`--no-confirm` オプション付き。

### ステップ 5: プッシュコマンド提示

**重要**: プッシュは自動実行しない。コマンドを表示するのみ。

```
## プッシュコマンド

以下のコマンドでリモートにプッシュしてください:

\`\`\`bash
git push -u origin {branch}
\`\`\`
```

### ステップ 6: PR 作成

github-pr-create スキルのワークフローに従って実行する。`--no-confirm` オプション付き。

### ステップ 7: 完了報告

```
## Backward フロー完了

### 作成された Issue
- #{issue番号}: {タイトル}

### ブランチ
- {ブランチ名}

### 作成された PR
- PR #{pr番号}: {タイトル}
- URL: {pr_url}

PR がマージされると Issue #{issue番号} は自動的にクローズされます。

### worktree クリーンアップ（--worktree モード時のみ）

PR マージ後、不要になった worktree を削除してください:
`/git-worktree` で gtr rm または gtr clean を実行
```

## 重要な注意事項

- プッシュは自動実行せず、コマンドを提示するのみ
- 変更がない場合はエラー終了する
- デフォルトブランチ上の場合のみブランチを作成する
- 未コミット変更がある場合のみコミットを実行する
- Issue 作成・コミット・PR 作成は各スキルのワークフローに従って実行する
- 変更がないまま Issue や PR を作成しない
- プッシュを自動実行しない

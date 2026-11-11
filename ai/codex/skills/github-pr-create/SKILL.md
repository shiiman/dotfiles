---
name: github-pr-create
description: 現在のブランチから PR を作成または更新する。「PR 作成」「PR を作って」「プルリク作成」「pull request」「PR 出して」「プルリクエスト」「レビュー依頼したい」「PR 更新」などで起動。変更内容を分析し適切な PR を生成。「ドラフトで」「develop 向けに」などは発話から判断する。
---

# Create PR

現在のブランチから PR を作成または更新します。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
/github-pr-create - PR 作成・更新

概要:
  現在のブランチから PR を作成または更新する。
  既存 PR がある場合は自動的に更新モードになる。
  ブランチ名から関連 Issue を自動検出し、PR テンプレートに従って本文を生成。

使用方法:
  /github-pr-create [タイトル]

オプション:
  --help  このヘルプを表示

指定の伝え方:
  「ドラフトで」「draft で」      → ドラフト PR として作成
  「develop 向けに」「base は X」  → 宛先ブランチを指定（既定: リポジトリのデフォルトブランチ）

例:
  /github-pr-create               # PR を作成または更新
  /github-pr-create "タイトル"     # タイトルを指定して PR 作成
  「ドラフトで PR を作って」        # ドラフト PR を作成
  「develop 向けに PR を作成」      # develop ブランチ向けに PR 作成

内部呼び出し用:
  --no-confirm  Compatibility flag for already authorized workflow calls
```

## Authorization

Use the global authorization policy and the current request to determine scope. An explicit request for this skill's action is sufficient authorization; do not ask again just to approve generated wording or require `--no-confirm`. The flag remains compatible with authorized workflow callers, but never grants permission by itself. Preserve security checks and ask only for missing authorization, a material scope change, or a concrete risk outside the approved scope.

## 起動時の自動判断

引数・発話から PR の作成条件を判定する。明示がなければ既定を採用する。

| 項目         | 既定                   | 判断ルール                                        |
| ------------ | ---------------------- | ------------------------------------------------- |
| 宛先ブランチ | リポジトリのデフォルト | 「develop 向けに」「base は X」等の発話があれば X |
| ドラフト     | 通常 PR                | 「ドラフトで」「draft で」「WIP」等あれば draft   |

## ワークフロー

### 1. 事前チェック

```bash
DEFAULT_BRANCH="$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name')"
CURRENT_BRANCH="$(git branch --show-current)"

# ブランチ状態確認
git status --short
git fetch origin
git log "origin/${CURRENT_BRANCH}..HEAD" --oneline 2>/dev/null
```

**Check branch state**:

- Inspect uncommitted changes and outgoing commits; do not terminate merely because the feature branch has not been pushed yet.
- A request to create a PR includes the normal push needed to publish its intended feature-branch commits. Verify the remote, destination, and outgoing diff before pushing; never force-push or push directly to the default branch under this authorization.
- If intended changes still need a commit, a request to create a PR from those changes authorizes the necessary commit after checks. Use `git-add-commit` for only the requested paths or hunks; leave unrelated edits and staged content untouched.
- Ask only if the intended scope cannot be determined safely, or publishing would include unapproved content. Respect an explicit instruction not to commit or push; report the resulting blocker instead of claiming PR completion.

### 2. 既存 PR の自動検出

```bash
gh pr list --head "${CURRENT_BRANCH}" --json number,title,url
```

- **既存 PR あり**: 更新モードに切替（タイトル・本文の更新を提案）
- **既存 PR なし**: 新規作成モード

### 3. 変更内容の確認

```bash
git log "origin/${DEFAULT_BRANCH}..HEAD" --oneline
git diff "origin/${DEFAULT_BRANCH}...HEAD" --stat
```

### 4. 関連 Issue の特定

以下から関連 Issue を判定:

- ブランチ名（`feature/5` → #5）
- コミットメッセージ
- If no related Issue can be established, omit the link; ask only if linking is required and the target is ambiguous.

### 5. 破壊的変更の検出

Inspect the commits and public API changes for breaking behavior. If a breaking change is verified, mark it in the Conventional Commits title and describe the impact without asking a separate question about the title punctuation. Creating a PR does not authorize deploying or merging the change.

### 6. PR 内容の作成

**タイトル**: Conventional Commits 形式

| タイプ   | 説明             | 例                                   |
| -------- | ---------------- | ------------------------------------ |
| feat     | 新機能           | `feat: shiiman-git プラグインを追加` |
| fix      | バグ修正         | `fix: Issue 番号の取得を修正`        |
| docs     | ドキュメント     | `docs: README を更新`                |
| refactor | リファクタリング | `refactor: スキル構造を整理`         |
| chore    | その他の変更     | `chore: 依存関係を更新`              |

Prepare a Japanese title and body from the verified diff, repository template, and actual validation results. If PR creation or update is authorized, proceed without requesting approval of the wording. `--no-confirm` is optional and does not expand authorization.

### 7. PR 作成・更新

**新規作成の場合**:

```bash
gh pr create \
  --title "feat: {変更内容の要約}" \
  --body "## 概要

{変更内容の説明}

## 変更内容

- {変更点1}
- {変更点2}

## 関連 Issue

Closes #{issue番号}

## テスト計画

- [ ] {テスト項目1}
- [ ] {テスト項目2}

## チェックリスト

- [x] 命名規則に従っている
- [x] README.md を更新した（必要な場合）
- [x] 動作確認済み"
```

ドラフトと判定した場合は `gh pr create --draft` を使用。宛先ブランチを判定した場合は `gh pr create --base {branch}` を付与する（既定はリポジトリのデフォルトブランチ）。

**更新の場合**:

```bash
gh pr edit {pr番号} \
  --title "{更新タイトル}" \
  --body "{更新本文}"
```

### 8. 結果報告

```
PR を{作成|更新}しました:

- URL: {pr_url}
- タイトル: {title}
- 関連 Issue: #{issue番号}
- モード: {新規作成|更新}

マージ後、Issue #{issue番号} は自動的にクローズされます。
```

## 重要な注意事項

- ✅ 既存 PR がある場合は自動的に更新モードになる
- ✅ Conventional Commits 形式のタイトル
- Reference a verified related Issue with `Closes #N`; omit the section if none exists.
- ✅ PR タイトルと本文は日本語
- Complete authorized commits and normal feature-branch push before creating the PR; preserve unrelated work.
- Do not invent an Issue or claim checks passed when they were not performed.

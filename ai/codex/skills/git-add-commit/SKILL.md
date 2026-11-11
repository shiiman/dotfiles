---
name: git-add-commit
description: 変更をステージング・コミットする。「コミット」「コミットして」「変更をコミット」「gitignore チェック」「コミット前チェック」「機密ファイル確認」などで起動。
---

# Add & Commit

セキュリティチェック → コミットメッセージ生成 → ステージング → コミットを行うスキル。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
/git-add-commit - Add & Commit

概要:
  セキュリティチェック + .gitignore チェックを実行し、
  変更をステージング・コミットする。

使用方法:
  /git-add-commit [オプション]

オプション:
  --help        このヘルプを表示
  --no-confirm  Compatibility flag for already authorized workflow calls
```

## Authorization

Use the global authorization policy and the current request to determine scope. An explicit request for this skill's action is sufficient authorization; do not ask again just to approve generated wording or require `--no-confirm`. The flag remains compatible with authorized workflow callers, but never grants permission by itself. Preserve security checks and ask only for missing authorization, a material scope change, or a concrete risk outside the approved scope.

## ワークフロー

### 1. 変更内容の確認

```bash
git status
git diff
git diff --staged
```

### 2. セキュリティチェック + .gitignore チェック

変更対象のファイルを以下のカテゴリでチェックする。

**機密ファイル**（検出時はコミットをブロック）:

| パターン                | 説明             |
| ----------------------- | ---------------- |
| `.env*`                 | 環境変数ファイル |
| `*.pem`, `*.key`        | 秘密鍵           |
| `credentials.json`      | 認証情報         |
| `*_secret*`, `*_token*` | シークレット     |
| `.aws/`, `.gcp/`        | クラウド認証情報 |

**一般的な無視対象**（検出時は警告 + .gitignore 追加を提案）:

| パターン                       | 説明                   |
| ------------------------------ | ---------------------- |
| `node_modules/`                | Node.js 依存パッケージ |
| `vendor/`                      | PHP/Go 依存パッケージ  |
| `.DS_Store`, `Thumbs.db`       | OS システムファイル    |
| `*.log`, `*.tmp`               | ログ・一時ファイル     |
| `dist/`, `build/`, `coverage/` | ビルド成果物           |

**IDE 設定ファイル**（検出時は警告 + .gitignore 追加を提案）:

| パターン         | 説明      |
| ---------------- | --------- |
| `.idea/`         | JetBrains |
| `.vscode/`       | VS Code   |
| `*.swp`, `*.swo` | Vim       |

**Handling detected files**:

- Do not stage secrets, unrelated user edits, or unintended generated files. Inspect actual content without exposing secrets; filenames alone do not establish whether a file contains credentials.
- Stage only authorized paths or hunks. Preserve the user's index and working tree; do not automatically reset pre-existing staged changes.
- Add clear task-generated artifacts to `.gitignore` when appropriate within the task. For ambiguous IDE or vendor files, follow repository conventions and leave unrelated files untouched. Report exclusions without requesting approval for every ignore pattern.
- If sensitive content is part of the intended commit, block that content and resolve it safely before continuing.

### 3. コミットメッセージ生成

変更内容を分析し、Conventional Commits 形式でメッセージを自動生成する。

**プレフィックス判定**:

| 変更内容                 | プレフィックス |
| ------------------------ | -------------- |
| 新規ファイル追加（機能） | `feat:`        |
| バグ修正                 | `fix:`         |
| ドキュメント変更         | `docs:`        |
| リファクタリング         | `refactor:`    |
| テスト追加・修正         | `test:`        |
| ビルド・依存関係         | `chore:`       |

### 4. Check authorization

If committing these changes is already requested, proceed after validation without another approval prompt. Otherwise prepare the intended diff and message before requesting commit authorization. `--no-confirm` does not bypass security checks or authorize unrelated changes.

### 5. ステージング

```bash
git add {対象ファイル}
```

### 6. コミット

Inspect the exact commit content before committing. The simple command below is appropriate only when the index contains exclusively authorized changes. If unrelated changes are already staged, use an isolated index or another scoped commit method that preserves the user's staged and unstaged work; never silently include or reset unrelated changes.

```bash
git commit -m "{コミットメッセージ}"
```

### 7. Push when authorized

A commit-only request does not authorize push. If push or PR creation is explicitly requested, verify the remote, branch, and outgoing commits, then execute the required normal push. For a new feature branch, use `git push -u origin {branch_name}`. Do not force-push, push to the default branch, publish unrelated work, or bypass repository checks without the necessary authorization. Otherwise report the commit result without asking an optional follow-up question.

## 重要な注意事項

- Reuse existing commit authorization; do not require a second confirmation.
- ✅ 機密ファイルを検出した場合はコミットをブロック（`--no-confirm` でも実行）
- ✅ Conventional Commits 形式を使用
- Never commit changes outside the authorized scope.
- Push only when authorized directly or required by an explicit PR creation request.
- ❌ デフォルトブランチへの直接コミットは避ける（警告を出す）

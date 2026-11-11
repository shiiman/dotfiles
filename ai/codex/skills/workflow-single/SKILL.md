---
name: workflow-single
description: Implement a requested task with a single agent, including only authorized commit, Issue, push, and PR steps. Use for workflow-single and explicit single-agent development requests. Default to implementation and validation without optional approval questions.
---

# Single Flow

シングルエージェントで計画書またはタスク説明を順次実装する開発フロー。

フラグは不要。タスクを伝えれば、git の状態・発話内容から実行条件を自動判断し、曖昧な点だけ確認する。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
workflow-single - シングルエージェント開発フロー

概要:
  計画書またはタスク説明を 1 エージェントで順次実装する。
  実装条件（Issue/PR・計画書・ブランチ・git）はフラグ不要で自動判断し、
  曖昧な点だけ確認する。

使用方法:
  workflow-single [タスク説明]
  workflow-single --help

オプション:
  --help  このヘルプを表示

例:
  workflow-single                          # 既存計画書から実装（あれば）
  workflow-single "ログイン機能を追加"      # タスク説明から実装
  workflow-single "認証を実装して PR まで"  # 実装・コミット・push・PR 作成
  workflow-single --help                   # ヘルプを表示

指定の伝え方（フラグの代わり）:
  - 「計画を立ててから」  → 計画書を作成してから実装
  - 「ブランチで」        → worktree ではなくブランチを作成
  - 「PR まで」           → コミット・通常の push・PR 作成まで実施
  - 「Issue と PR まで」   → Issue 作成も含めて実施
  - 「コミットだけ」      → 検証後にコミットし、push・Issue・PR は作成しない
```

## 前提条件

- `gh` コマンドが利用可能
- `gh auth status` が成功する（GitHub CLI 認証済み）

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

- 成功 → git モード（ブランチ/worktree を作成）
- 失敗 → no-git モード（ブランチ作成を省略し、実装とサマリー出力のみ）

### 計画書の扱いの判定

1. 「計画を立ててから」等の依頼がある → **Plan**: write the requested plan to `.codex/plans/`. If implementation is also requested, proceed after explaining it; wait only when the user explicitly requests plan approval or a material decision remains unresolved
2. タスク説明がある → **直接実行**: タスク説明をそのまま実装の指針にする（計画書を作らない）
3. タスク説明なし → **既存計画書**: 最新の計画書を読み込む

```bash
ls -t ~/.codex/plans/*.md 2>/dev/null | head -1
```

計画書が見つからなければ「タスク説明を教えてください。または計画を立ててから実装することもできます」と案内して終了。

## 実行フロー（共通）

```text
[Issue 作成が許可済みの場合のみ] Issue 作成 →
ブランチ/worktree 作成 → 実装 → セキュリティチェック＆自己レビュー →
[許可済みの操作のみ] コミット → push → PR 作成 → 完了報告
[連携なし] コミットメッセージ出力で終了
```

### Step A: Create an Issue only when authorized

`github-issue-create` スキルのワークフローに従い、`--no-confirm` オプションで Issue を作成する。タスク内容を 50 文字以内のタイトルにし、本文は「## 概要 / ## タスク（チェックボックス）/ ## 完了条件」で構成する。ラベルは内容に応じて `enhancement` / `bug` / `documentation` / `improvement` を付与。

作成された Issue 番号を後続ステップで使う。

### ステップ 1: ブランチ / worktree 作成

git モードのみ実施（no-git モードはスキップ）。

- worktree（既定）: `github-worktree-create` スキルのワークフローに従う
- ブランチ: `github-branch-create` スキルのワークフローに従う
- Pass an Issue number only when a verified related Issue exists; otherwise use a task-derived branch name.

ユーザーがベースブランチを明示した場合はそちらを優先する。

### ステップ 2: 実装

計画書またはタスク説明に基づいて実装する。

1. 必要なファイルを特定
2. コード変更を実施
3. 動作確認（可能な場合）
4. Update checkboxes only on an authorized, verified Issue, and only for tasks actually completed

### ステップ 3: セキュリティチェック＆自己レビュー

```bash
git status
git diff
```

- 機密ファイルを検出したら警告: `.env*`（環境変数）、`*.pem` / `*.key`（秘密鍵）、`credentials.json`（認証情報）、`node_modules/` / `vendor/`（依存）
- 自己レビュー観点: コード品質・命名規則 / セキュリティ（OWASP Top 10）/ パフォーマンス（N+1・メモリリーク）

### Step 4: Validate and continue within authorization

Summarize the verified changes and checks in a progress update, then continue with the authorized completion actions. Do not pause merely to approve the diff or commit message. If a concrete risk or unresolved scope decision requires confirmation, prepare the reviewable result and ask only about that decision.

## 仕上げ

### Authorized completion actions

Execute only the following actions covered by the authorized completion scope; no repeated approval is needed.

1. Update only verified completed checkboxes on an authorized Issue; never mark unfinished tasks complete.
2. コミット: `git-add-commit` スキルのワークフローに従い、`--no-confirm` オプションでコミットする
3. If push or PR creation is authorized, verify the remote, destination branch, and outgoing commits, then execute `git push -u origin {branch}` for the intended feature branch. Do not force-push, push directly to the default branch, or include unrelated work.

4. PR 作成: `github-pr-create` スキルのワークフローに従い、`--no-confirm` オプションで PR を作成する。Use a Japanese summary, changes, and validation results. Include `Closes #N` only for a verified related Issue; omit the Issue section otherwise
5. Report only actions actually completed; omit Issue or PR placeholders for actions not performed:

   ```text
   ## 開発フロー完了

   ### 作成された Issue
   - #{issue番号}: {タイトル}

   ### 作成されたブランチ / worktree
   - {ブランチ名}
   - パス: {worktree のパス}（worktree モード時のみ）

   ### 作成された PR
   - PR #{pr番号}: {タイトル} / {pr_url}

   PR がマージされると Issue #{issue番号} は自動的にクローズされます。

   ### worktree クリーンアップ（worktree モード時のみ）
   PR マージ後、`/git-worktree` で gtr rm または gtr clean を実行してください。
   ```

### Issue/PR 連携なし（軽量）

For implementation-only requests, report changes and validation without committing, pushing, or creating an Issue/PR. For an explicit commit-only request, validate and commit the intended changes, then report the commit. Do not ask an optional follow-up question.

```text
## 実装完了

### 作成されたブランチ / worktree（git モード時のみ）
- {ブランチ名}
- パス: {worktree のパス}（worktree モード時のみ）

### 変更サマリー
{git diff --stat}

### 推奨コミットメッセージ
{Conventional Commits message following repository and global instructions}

### 検証結果
{実行したチェック・結果・残課題}
```

## 重要な注意事項

- ✅ ユーザーにフラグを入力させない（git・worktree/branch・計画書・Issue/PR を自動判断、曖昧なら確認）
- ✅ 計画書作成は「計画を立ててから」と依頼されたときのみ実施
- Continue authorized completion steps without a second confirmation.
- ✅ 機密ファイルを警告・除外する
- Follow repository commit conventions and global instructions; do not invent unsupported configuration keys.
- ❌ デフォルトブランチで直接作業・コミットしない
- Execute each external or Git completion action only within its independently authorized scope.

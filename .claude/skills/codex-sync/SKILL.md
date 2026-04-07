---
name: codex-sync
description: claude-code-plugins リポジトリの PR を確認し、codex スキルに未反映の変更を取り込む。「codex sync」「codex スキル同期」「プラグイン同期」「スキル同期」「PR 取り込み」などで起動。
allowed-tools: Read, Edit, Bash, Glob, Grep
argument-hint: "[PR番号...] [--repo owner/repo] [--limit N] [--help]"
---

# Codex Sync

claude-code-plugins リポジトリの PR を確認し、codex スキルに未反映の変更を取り込む。

## Help

`$ARGUMENTS` に `--help` が含まれる場合、以下を表示して終了:

```text
/codex-sync - Codex スキル同期

概要:
  claude-code-plugins リポジトリのマージ済み PR を確認し、
  ai/codex/skills/ に未反映の変更を特定・取り込みます。

使用方法:
  /codex-sync [PR番号...] [オプション]

オプション:
  --repo owner/repo  対象リポジトリ（デフォルト: shiiman/claude-code-plugins）
  --limit N          取得する最近のPR件数（デフォルト: 20）
  --help             このヘルプを表示

例:
  /codex-sync                  # 最近のPR一覧を表示して選択
  /codex-sync 196              # PR #196 のみ確認
  /codex-sync 182 190 196      # 複数の PR を一括確認
```

## 前提条件

- `gh` コマンドが利用可能（`gh auth status` が成功すること）

## ファイルマッピング規則

claude-code-plugins のスキルファイルを codex スキルのパスに変換する規則:

| リモートパス                                           | ローカル codex パス                             |
| ------------------------------------------------------ | ----------------------------------------------- |
| `plugins/shiiman-{category}/skills/{skill}/SKILL.md`   | `ai/codex/skills/{category}-{skill}/SKILL.md`   |
| `plugins/shiiman-{category}/skills/{skill}/assets/...` | `ai/codex/skills/{category}-{skill}/assets/...` |

**例**:

- `plugins/shiiman-github/skills/worktree-create/SKILL.md` → `ai/codex/skills/github-worktree-create/SKILL.md`
- `plugins/shiiman-workflow/skills/single/SKILL.md` → `ai/codex/skills/workflow-single/SKILL.md`
- `plugins/shiiman-google/skills/notebooklm-infographic/SKILL.md` → `ai/codex/skills/google-notebooklm-infographic/SKILL.md`

**codex 非対応スキル（スキップ）**:

Claude Code 固有の機能を使用するため、codex に対応するスキルが存在しない:

- `agent-team`、`agent-team-issue`（Claude Code の Agent Teams を使用）

## ワークフロー

### 1. 対象 PR の決定

**`$ARGUMENTS` に PR 番号が指定されている場合**:

指定された番号のリストをそのまま使用する。

**PR 番号が指定されていない場合**:

```bash
REPO="${--repo の値 または shiiman/claude-code-plugins}"
LIMIT="${--limit の値 または 20}"
gh pr list --repo "$REPO" --state merged --limit "$LIMIT" \
  --json number,title,mergedAt,labels \
  --template '{{range .}}#{{.number}} {{.mergedAt | timeago}} {{.title}}\n{{end}}'
```

一覧をユーザーに提示し、取り込む PR 番号を確認する。複数指定可。

### 2. 各 PR の差分を取得

対象 PR ごとに:

```bash
gh pr view {PR番号} --repo "$REPO" --json number,title,body,mergedAt
gh pr diff {PR番号} --repo "$REPO"
```

差分から変更された `SKILL.md` および `assets/` 配下のファイルを抽出する。

### 3. ファイルマッピング

変更されたファイルパスをファイルマッピング規則に従って変換する。

- `plugins/{plugin}.claude-plugin/` 配下のファイル（plugin.json, marketplace.json など）はスキップ
- `README.md` はスキップ
- codex 非対応スキル（`agent-team`, `agent-team-issue`）はスキップ
- マッピング後のパスが `ai/codex/skills/` に存在しないスキルは「新規スキル候補」として別途報告する

### 4. リモート最新版の取得

マッピングされたファイルごとに、リモートの現在の内容を取得する:

```bash
gh api repos/{REPO}/contents/{リモートパス} --jq '.content' | base64 -d
```

### 5. ローカルとの差分確認

マッピングされた各ファイルについて:

1. ローカルファイル（`ai/codex/skills/...`）を Read で読み込む
2. リモート最新版と比較し、差分を特定する

**差分の分類**:

- **A. 意味的な変更（取り込み必要）**: 機能追加・バグ修正・手順変更など
- **B. プラットフォーム差異（スキップ）**: 以下は codex/claude-code 間の仕様差異なのでスキップ:
  - スキル名の参照形式（`shiiman-github:worktree-create` vs `github-worktree-create`）
  - frontmatter のフィールド（`argument-hint`, `context: fork`, `user-invocable`）
  - パス（`.claude/` vs `.codex/`、`claude/settings.json` vs `config.toml`）
  - MCP ツール名 prefix（`mcp__multi-agent-mcp__` の有無）
  - 引数参照（`$ARGUMENTS` vs テキスト説明）

### 6. 結果報告

以下の形式でサマリを表示する:

```
## PR #NNN: {タイトル}

### 取り込み対象の変更
- ai/codex/skills/XXX/SKILL.md
  → {変更の概要（1〜2行）}

### スキップ（プラットフォーム差異のみ）
- ai/codex/skills/YYY/SKILL.md

### 新規スキル候補（codex 未対応）
- ai/codex/skills/ZZZ/ （新規作成が必要）
```

変更がない場合は「取り込むべき変更はありませんでした」と表示して終了。

### 7. ユーザー確認と適用

取り込み対象ファイルを一覧表示し、適用する変更を確認する。

- 「すべて適用」「一部適用」「スキップ」から選択
- 「一部適用」の場合は各ファイルを個別に確認

ユーザーが承認したファイルについて:

1. ローカルファイルを読み込む（Edit 使用のため必須）
2. 意味的な変更のみ Edit で適用（プラットフォーム差異は自動的に codex 版に翻訳して適用）

### 8. フォーマット

変更したファイルがある場合:

```bash
npm run format
```

フォーマット完了後、変更ファイル一覧とコミットメッセージ案を表示する。

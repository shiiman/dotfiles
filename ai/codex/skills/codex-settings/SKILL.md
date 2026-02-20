---
name: codex-settings
description: Codex 設定の表示・更新を統合管理する。「Codex 設定管理」「設定を表示」「settings を更新」「権限設定を変更」「設定ファイル管理」「codex settings」などで起動。引数があれば優先し、なければ発話内容から view/update を判定。
---

# Codex Settings Manage

Codex の設定ファイル（TOML 形式）の表示と更新を一つのスキルで管理します。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
/codex-settings - Codex 設定管理

概要:
  Codex 設定の表示・更新を統合管理する。
  引数があれば優先し、なければ発話内容から操作を判定。

使用方法:
  /codex-settings [操作] [オプション]

操作:
  view          設定を表示
  update        config.toml を更新

オプション:
  --help        このヘルプを表示

例:
  /codex-settings              # 発話内容から操作を判定
  /codex-settings view         # 設定を表示
  /codex-settings update       # config.toml を更新
```

## 設定ファイル

Codex の設定は `~/.codex/config.toml` で管理します。

### 設定ファイルの構造

```toml
# ~/.codex/config.toml

# モデル設定
model = "o4-mini"
# model = "o3"
# model = "gpt-4.1"

# 承認モード: "suggest" | "auto-edit" | "full-auto"
approval_mode = "suggest"

# サンドボックス: "docker-only" | "local-only" | "remote-only" | "flexible"
sandbox = "flexible"

# MCP サーバー設定
[mcp_servers.github]
type = "stdio"
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]

[mcp_servers.github.env]
GITHUB_PERSONAL_ACCESS_TOKEN = "<your-token>"
```

## 実行手順

### 1. 操作種別の決定

- 引数が指定されていれば引数を優先
- 引数がない場合は発話内容から以下を判定:
  - 表示系: view
  - 更新系: update

### 2. 操作の実行

#### view

1. `~/.codex/config.toml` を読み込む
2. 設定内容をセクション別に整形表示

#### update

1. `~/.codex/config.toml` の存在確認（なければ作成フローへ）
2. 変更内容を確認（model / approval_mode / sandbox / mcp_servers / その他）
3. 既存設定を保持したマージ更新を実施
4. 更新結果を報告

## ファイル未存在時の作成

- `~/.codex` ディレクトリがない場合は `mkdir -p ~/.codex`
- テンプレートから新規作成可能

### config.toml 基本テンプレート

```toml
# Codex 設定ファイル

# モデル設定
model = "o4-mini"

# 承認モード: "suggest" | "auto-edit" | "full-auto"
approval_mode = "suggest"

# サンドボックス: "docker-only" | "local-only" | "remote-only" | "flexible"
sandbox = "flexible"
```

## 出力フォーマット

```markdown
## Codex Settings 管理

### 実行モード

- view / update

### 結果

- 対象ファイル: ~/.codex/config.toml
- 変更点: 箇条書きで要約
- ステータス: 成功 / 失敗
```

## 重要な注意事項

- 既存設定を保持したマージ更新を行う
- 機密情報は表示時にマスクする
- ファイルがなければテンプレートで作成できる
- 設定ファイル全体を無条件上書きしない

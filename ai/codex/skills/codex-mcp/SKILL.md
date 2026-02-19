---
name: codex-mcp
description: MCP サーバーの設定管理を案内する。「MCP 管理」「MCP 一覧」「MCP を追加」「MCP を削除」「MCP サーバー管理」「MCP 設定」「MCP 操作」などで起動。引数があれば優先し、なければ発話内容から list/install/remove を判定。
---

# Codex MCP Manage

Codex の `config.toml` における MCP サーバー設定の管理を支援します。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
/codex-mcp - MCP サーバー管理

概要:
  Codex の config.toml における MCP サーバー設定の管理を案内する。
  引数があれば優先し、なければ発話内容から操作を判定。

使用方法:
  /codex-mcp [操作] [オプション]

操作:
  list     MCP サーバー一覧を表示
  install  MCP サーバーを追加
  remove   MCP サーバーを削除

オプション:
  --help   このヘルプを表示

例:
  /codex-mcp              # 発話内容から操作を判定
  /codex-mcp list         # MCP サーバー一覧を表示
  /codex-mcp install      # MCP サーバーを追加
  /codex-mcp remove       # MCP サーバーを削除
```

## 設定ファイル

Codex の MCP 設定は `~/.codex/config.toml` の `[mcp_servers]` セクションで管理します。

### 設定例

```toml
# ~/.codex/config.toml

[mcp_servers.github]
type = "stdio"
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]

[mcp_servers.github.env]
GITHUB_PERSONAL_ACCESS_TOKEN = "<your-token>"

[mcp_servers.filesystem]
type = "stdio"
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]

[mcp_servers.postgres]
type = "stdio"
command = "npx"
args = ["-y", "@modelcontextprotocol/server-postgres"]

[mcp_servers.postgres.env]
DATABASE_URL = "postgresql://user:pass@localhost/db"
```

## 実行手順

### 1. 操作種別の決定

- 引数が指定されていれば引数を優先
- 引数がない場合は発話内容から以下を判定:
  - 一覧系: list
  - 追加系: install
  - 削除系: remove

### 2. 操作の実行

#### list

1. `~/.codex/config.toml` を読み込む
2. `[mcp_servers]` セクションの内容を整形して表示

#### install

1. ユーザーに以下を確認:
   - サーバー名（例: github, filesystem, puppeteer）
   - 必要な環境変数
2. `~/.codex/config.toml` に `[mcp_servers.<name>]` セクションを追加
3. 必要な環境変数がある場合は `[mcp_servers.<name>.env]` も追加

#### remove

1. `~/.codex/config.toml` の `[mcp_servers]` セクションを表示
2. ユーザーに削除対象のサーバー名を確認
3. 該当する `[mcp_servers.<name>]` セクションを削除

## 人気の MCP サーバー

| 名前       | 説明                 | 必要な環境変数               |
| ---------- | -------------------- | ---------------------------- |
| github     | GitHub API 操作      | GITHUB_PERSONAL_ACCESS_TOKEN |
| filesystem | ファイルシステム操作 | なし                         |
| puppeteer  | ブラウザ自動化       | なし                         |
| postgres   | PostgreSQL 操作      | DATABASE_URL                 |
| sqlite     | SQLite 操作          | なし                         |

## 出力フォーマット

```markdown
## MCP サーバー管理

### 実行モード

- list / install / remove

### 結果

- 対象ファイル: ~/.codex/config.toml
- ステータス: 成功 / 失敗
- 補足: 必要なら環境変数の案内
```

## 重要な注意事項

- install/remove は実行前に必ず確認する
- list ではサーバーが0件のケースを考慮する
- 必要な環境変数を案内する
- 環境変数の値そのものは設定しない

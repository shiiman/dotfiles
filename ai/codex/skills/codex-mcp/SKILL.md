---
name: codex-mcp
description: MCP サーバーの設定管理を案内する。「MCP 管理」「MCP 一覧」「MCP を追加」「MCP を削除」「MCP サーバー管理」「MCP 設定」「MCP 操作」などで起動。引数があれば優先し、なければ発話内容から list/install/remove を判定。
---

# Codex MCP Manage

Codex CLI の `codex mcp` コマンドを使用して MCP サーバー設定を管理します。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
/codex-mcp - MCP サーバー管理

概要:
  Codex CLI の `codex mcp` コマンドで MCP サーバー設定を管理する。
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

## 実行手順

### 1. 操作種別の決定

- 引数が指定されていれば引数を優先
- 引数がない場合は発話内容から以下を判定:
  - 一覧系: list
  - 追加系: install
  - 削除系: remove

### 2. 操作の実行

#### list

```bash
codex mcp list
```

JSON 形式で確認したい場合:

```bash
codex mcp list --json
```

#### install

1. ユーザーに以下を確認:
   - サーバー名（例: github, filesystem, puppeteer）
   - コマンドと引数
   - 必要な環境変数

2. `codex mcp add` コマンドで追加:

```bash
# stdio サーバーの追加例
codex mcp add <name> -- <command> [args...]

# 環境変数付きの例
codex mcp add github --env GITHUB_PERSONAL_ACCESS_TOKEN=<token> -- npx -y @modelcontextprotocol/server-github

# HTTP サーバーの追加例
codex mcp add <name> --url <url>
```

#### remove

1. `codex mcp list` で現在のサーバー一覧を表示
2. ユーザーに削除対象のサーバー名を確認
3. `codex mcp remove` で削除:

```bash
codex mcp remove <name>
```

## 出力フォーマット

```markdown
## MCP サーバー管理

### 実行モード

- list / install / remove

### 結果

- ステータス: 成功 / 失敗
- 補足: 必要なら環境変数の案内
```

## 重要な注意事項

- install/remove は実行前に必ず確認する
- list ではサーバーが0件のケースを考慮する
- 必要な環境変数を案内する
- 環境変数の値そのものは設定しない

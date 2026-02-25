---
name: google-notebooklm-deepresearch
description: NotebookLM でディープリサーチを実行する。「ディープリサーチ」「深い調査」「NotebookLM リサーチ」「Web 調査」「ノートブック調査」「深掘りリサーチ」「NotebookLM で調べて」などで起動。
---

# NotebookLM Deep Research

NotebookLM でノートブックを新規作成し、ディープリサーチを実行してソースをインポートする。

## Help

ユーザーが `--help` を指定した場合、以下を表示して終了:

```text
/google-notebooklm-deepresearch - NotebookLM Deep Research

概要:
  ノートブックを新規作成し、ディープリサーチを実行してソースをインポートします。

使用方法:
  /google-notebooklm-deepresearch [オプション]

オプション:
  --help  このヘルプを表示
```

## 前提条件

- notebooklm-mcp MCP サーバーが codex に設定されていること
- 設定されていない場合は「notebooklm-mcp MCP サーバーが設定されていません。`codex mcp add` で設定してください。」と案内して終了する

## 使用する MCP ツール

- `mcp__notebooklm-mcp__notebook_create`
- `mcp__notebooklm-mcp__research_start`
- `mcp__notebooklm-mcp__research_poll`
- `mcp__notebooklm-mcp__research_import`

## ワークフロー

### 1. ノートブック名の入力

ユーザー入力にノートブック名が含まれていればそれを使用する。なければノートブック名を質問する。

### 2. ノートブック作成

```
mcp__notebooklm-mcp__notebook_create(title="{ノートブック名}")
```

作成されたノートブックの `notebook_id` を保持する。

### 3. リサーチクエリの入力

ユーザーにリサーチクエリを質問する。

### 4. ディープリサーチ開始

```
mcp__notebooklm-mcp__research_start(
  notebook_id="{notebook_id}",
  query="{リサーチクエリ}",
  source_type="web",
  mode="deep"
)
```

戻り値から `task_id` を保持する。

### 5. 初回待機

ディープリサーチは時間がかかるため、まず 3 分待機する。

```bash
sleep 180
```

### 6. ポーリング（完了待ち）

以下の手順でステータスをポーリングする:

1. `mcp__notebooklm-mcp__research_poll(notebook_id="{notebook_id}")` を呼び出す
2. status を確認:
   - **完了** → ステップ 7 へ
   - **処理中** → `sleep 60` で 1 分待機してから再度 1 へ
   - **エラー** → ユーザーにエラー内容を報告して終了
3. 最大 15 分（初回 3 分 + ポーリング 12 回 × 1 分）まで繰り返す
4. タイムアウトした場合はユーザーに「ディープリサーチがまだ完了していません。NotebookLM の Web UI で直接確認してください。」と報告する

### 7. リサーチ結果のインポート

```
mcp__notebooklm-mcp__research_import(
  notebook_id="{notebook_id}",
  task_id="{task_id}"
)
```

`sources` パラメータは省略し、全件自動インポートする。

### 8. 完了報告

インポート結果をユーザーに表示する。ノートブック名、インポートされたソース数を含める。

## 注意事項

- notebooklm-mcp MCP サーバーが起動していない場合、MCP ツールが利用できない。MCP サーバーの設定確認を案内する
- 認証エラーの場合は `mcp__notebooklm-mcp__refresh_auth` での再認証を案内する
- ディープリサーチは完了まで数分〜十数分かかる場合がある

---
name: codex-update
description: Codex CLI のバージョン確認・更新を実行する。「Codex を更新」「Codex をアップデート」「codex update」「Codex のバージョン確認」「最新版にして」「Codex を最新に」「Codex 本体更新」などで起動。引数があれば優先し、なければ発話内容から version/update を判定。
---

# Codex Update

Codex CLI のバージョン確認と更新を行います。

## Help

ユーザー入力に `--help` が含まれる場合、以下を表示して終了:

```text
/codex-update - Codex 更新

概要:
  Codex CLI のバージョン確認・更新を実行する。
  Homebrew 管理の場合は brew upgrade を使用。

使用方法:
  /codex-update [操作] [オプション]

操作:
  version        現在のバージョンを確認
  update         Codex CLI を更新

オプション:
  --help         このヘルプを表示

例:
  /codex-update                # 発話内容から操作を判定
  /codex-update version        # バージョン確認
  /codex-update update         # Codex を更新
```

## 実行手順

### 1. 操作種別の決定

- 引数が指定されていれば引数を優先
- 引数がない場合は発話内容から以下を判定:
  - 確認系: version
  - 更新系: update

### 2. 操作の実行

#### version

1. `codex --version` で現在のバージョンを表示
2. 更新したい場合は `update` モード実行を案内

#### update

1. `codex --version` で更新前バージョンを取得
2. 実行前にユーザーに確認を取る
3. インストール方法を判定:
   - macOS かつ `brew list --versions codex` が成功する場合: `brew upgrade codex`
   - それ以外: `npm install -g @openai/codex`
4. `codex --version` で更新後バージョンを確認
5. 結果と必要な次アクション（再起動など）を報告

## 出力フォーマット

```markdown
## Codex 更新

### 実行モード

- version / update

### 結果

- 更新前: x.y.z
- 更新後: x.y.z（version 時は省略可）
- ステータス: 成功 / 失敗
- 補足: 必要に応じて再起動案内
```

## 重要な注意事項

- update 実行前に必ず確認する
- Homebrew 管理の Codex は `brew upgrade codex` を使う
- 更新前後のバージョン差分を明示する
- 失敗時はエラーメッセージをそのまま報告する
- 失敗を推測で補完しない

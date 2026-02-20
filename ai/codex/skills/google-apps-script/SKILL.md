---
name: google-apps-script
description: Google Apps Script プロジェクトを新規作成・コード更新する。「GAS 作成」「Apps Script 作成」「スクリプト作成」「GAS 更新」「Apps Script 更新」「スクリプト編集」「コードを更新」などで起動。
---

# Apps Script Editor

Google Apps Script プロジェクトの新規作成・コード更新を行います。

## Help

ユーザーが `--help` を指定した場合、以下を表示して終了:

```text
/google-apps-script - Apps Script Editor

概要:
  Google Apps Script プロジェクトの新規作成・コード更新を行います。

使用方法:
  /google-apps-script [オプション]

オプション:
  --help  このヘルプを表示
```

## ワークフロー

### 新規作成

```bash
python ~/.codex/lib/google/scripts/google_apps_script.py create \
  --name "スクリプト名" \
  --parent-id "親ドキュメントID"
```

| オプション    | 必須 | 説明                                                 |
| ------------- | ---- | ---------------------------------------------------- |
| `--name`      | Yes  | スクリプト名                                         |
| `--parent-id` | No   | 親ドキュメントID（スプレッドシート等に紐付ける場合） |

### コード更新

```bash
python ~/.codex/lib/google/scripts/google_apps_script.py update \
  --script-id "スクリプトID" \
  --filename "Code.gs" \
  --code "function myFunction() { ... }"
```

| オプション    | 必須 | 説明                            |
| ------------- | ---- | ------------------------------- |
| `--script-id` | Yes  | スクリプトID                    |
| `--filename`  | Yes  | ファイル名（.gs, .html, .json） |
| `--code`      | Yes  | コード内容                      |

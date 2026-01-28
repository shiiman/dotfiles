---
name: lint
description: シェルスクリプトに対してshellcheckを実行し、警告があれば修正提案する。
allowed-tools: Read, Edit, Bash, Glob, Grep
argument-hint: "[パス] [--fix|--check]"
---

# Lint - Run shellcheck on Shell Scripts

シェルスクリプトに対してshellcheckを実行し、警告があれば修正提案する。

## Help

`$ARGUMENTS` に `--help` が含まれる場合、以下を表示して終了:

```text
/lint - Lint実行

概要:
  シェルスクリプトに対してshellcheckを実行し、警告があれば修正提案する。

使用方法:
  /lint [パス] [オプション]

オプション:
  --help   このヘルプを表示
  --fix    修正提案を適用（確認あり）
  --check  チェックのみ（修正しない）

例:
  /lint                    # 変更された.shファイルをlint
  /lint ./dotfile_setup.sh # 指定ファイルをlint
  /lint --check            # チェックのみ
```

## Instructions

1. **変更ファイル検出**:

   ```bash
   # staged + unstaged .sh files
   git diff --cached --name-only -- '*.sh' && git diff --name-only -- '*.sh'
   ```

   - `$ARGUMENTS` にファイルパスが指定されている場合はそれを使用

2. **shellcheck実行**:

   ```bash
   # 単一ファイル
   shellcheck path/to/script.sh

   # 全.shファイル
   find . -name "*.sh" -type f -exec shellcheck {} \;

   # JSON出力（詳細分析用）
   shellcheck -f json path/to/script.sh
   ```

3. **lint実行**:
   - `lint-executor` サブエージェントを起動して対象ファイルをlint
   - 警告/エラーがあれば修正提案

4. **結果報告**:
   - lint結果のサマリ
   - 修正提案一覧
   - 修正できなかった警告（あれば）

## Usage

```bash
/lint                    # 変更された.shファイルをlint
/lint ./dotfile_setup.sh # 指定ファイルをlint
/lint .                  # カレントディレクトリの全.shファイルをlint
/lint --fix              # 修正提案を適用
/lint --check            # チェックのみ（修正しない）
```

## Common shellcheck Warnings

| コード | 内容 | 修正方法 |
|--------|------|----------|
| SC2086 | 変数クォート不足 | `"$var"` に変更 |
| SC2046 | コマンド置換クォート不足 | `"$(cmd)"` に変更 |
| SC2006 | バッククォート使用 | `$()` に変更 |
| SC2034 | 未使用変数 | 削除または使用 |
| SC2155 | declare/localで代入 | 分離して記述 |

## Notes

- shellcheckがインストールされていない場合はインストール方法を案内
- **`# shellcheck disable=SCxxxx` でエラーを隠す修正は絶対禁止** - 根本的なコード修正で対応すること

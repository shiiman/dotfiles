---
name: commit
description: 変更をレビューし、コミットする。シェルスクリプトはshellcheckを実行してからコミット。
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash
argument-hint: "[--skip-review|--amend]"
---

# Commit

変更をレビューし、コミットする。

## Help

`$ARGUMENTS` に `--help` が含まれる場合、以下を表示して終了:

```text
/commit - コミット

概要:
  変更をレビューし、コミットする。
  シェルスクリプトはshellcheckを実行してからコミット。

使用方法:
  /commit [オプション]

オプション:
  --help         このヘルプを表示
  --skip-review  レビューをスキップ
  --amend        直前のコミットを修正（未プッシュの場合のみ）

例:
  /commit                # 標準コミット
  /commit --skip-review  # レビューをスキップ
  /commit --amend        # 直前のコミットを修正
```

## Instructions

### 1. 変更ファイル確認

```bash
git status --short
git diff --cached --name-only
git diff --name-only
```

### 2. シェルスクリプトのlint（.shファイルがある場合）

```bash
# 変更された.shファイルをshellcheck
git diff --cached --name-only -- '*.sh' | xargs -I {} shellcheck {}
```

- shellcheckエラーがあれば修正を促す

### 3. レビュー

`--skip-review` がない場合:

```bash
/review --staged
```

- High 以上の指摘があれば修正を促す

### 4. 変更のステージングとコミット

```bash
git add -A
```

変更内容を分析して**1行の**コミットメッセージを生成:

```bash
git commit -m '<type>(<scope>): <subject>'
```

- **type**: feat, fix, docs, refactor, chore から選択
- **scope**: 変更の主な対象（例: bash, zsh, brew, setup, vim）
- **subject**: 変更内容の要約（50文字以内、日本語OK）

### 5. 結果報告

- コミットハッシュ
- 変更ファイル数
- 実行したチェックの結果サマリ

## Usage

```bash
/commit                    # 標準コミット（lint + レビュー + コミット）
/commit --skip-review      # レビューをスキップ
/commit --amend            # 直前のコミットを修正（未プッシュの場合のみ）
```

## Commit Message Format

**1行で簡潔に**（50文字以内推奨）:

```text
<type>(<scope>): <subject>
```

### Type

| Type | 説明 |
|------|------|
| feat | 新機能・新設定 |
| fix | バグ修正・設定修正 |
| docs | ドキュメントのみの変更 |
| refactor | リファクタリング（機能変更なし） |
| chore | その他の変更 |

### Scope Examples

- `bash`: .bashrc 関連
- `zsh`: .zshrc 関連
- `git`: .gitconfig 関連
- `vim`: .vimrc 関連
- `brew`: Brewfile 関連
- `setup`: セットアップスクリプト関連
- `tmux`: .tmux.conf 関連

## Notes

- `--amend` は未プッシュのコミットのみ対象
- High 以上のレビュー指摘は必ず修正してからコミット

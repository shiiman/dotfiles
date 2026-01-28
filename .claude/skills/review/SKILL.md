---
name: review
description: 変更内容を詳細にレビューし、問題点と改善提案を提示する。セキュリティ、シェルスクリプト品質、互換性を確認。
allowed-tools: Read, Grep, Glob, Bash
argument-hint: "[対象] [--staged|--unstaged|--security]"
---

# Code Review

変更内容を詳細にレビューし、問題点と改善提案を提示する。

## Help

`$ARGUMENTS` に `--help` が含まれる場合、以下を表示して終了:

```text
/review - コードレビュー

概要:
  変更内容を詳細にレビューし、問題点と改善提案を提示する。
  セキュリティ、シェルスクリプト品質、互換性を確認。

使用方法:
  /review [対象] [オプション]

オプション:
  --help          このヘルプを表示
  --staged        staged変更のみレビュー
  --unstaged      unstaged変更のみレビュー
  --security      セキュリティ観点のみ

例:
  /review                      # ブランチ全体の変更をレビュー
  /review --staged             # staged変更のみ
  /review --security           # セキュリティ観点のみ
  /review path/to/script.sh    # 指定ファイルをレビュー
```

## Instructions

1. **変更内容取得**:

   ```bash
   # デフォルトブランチを取得
   DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)

   # staged changes
   git diff --cached

   # unstaged changes
   git diff

   # commit済み（ブランチ全体の変更）
   git diff $DEFAULT_BRANCH...HEAD

   # 変更ファイル一覧
   git diff --cached --name-only && git diff --name-only
   ```

   - デフォルト: ブランチ全体の変更（デフォルトブランチからの差分）
   - `$ARGUMENTS` に `--staged` がある場合: staged変更のみ
   - `$ARGUMENTS` に `--unstaged` がある場合: unstaged変更のみ
   - `$ARGUMENTS` にファイルパスがある場合: 指定ファイルのみ

2. **セキュリティレビュー**:
   - **認証情報**:
     - ハードコードされたパスワード、APIキー、トークン
     - 機密情報の環境変数からの取得確認
   - **コマンドインジェクション**:
     - ユーザー入力のサニタイズ
     - `eval` の使用
     - 変数展開の適切なクォート
   - **ファイル権限**:
     - 実行権限の設定
     - 機密ファイルのパーミッション

3. **シェルスクリプト品質レビュー**:
   - **shellcheck実行**（.shファイルの場合）:
     ```bash
     shellcheck path/to/script.sh
     ```
   - **変数クォート**:
     - `"$variable"` 形式の使用
     - ワードスプリッティング防止
   - **エラーハンドリング**:
     - `set -e` / `set -u` の使用
     - 明示的なエラーチェック

4. **互換性レビュー**:
   - **POSIX互換性**:
     - Bash固有機能の使用箇所
     - 移植可能な代替案
   - **シェルバージョン**:
     - Bash 3.2+（macOSデフォルト）
     - Zsh 5.0+

5. **結果報告**:
   - **Critical**: セキュリティリスク、認証情報露出
   - **High**: shellcheckエラー、互換性問題
   - **Medium**: コード品質向上
   - **Low**: スタイル提案

## Usage

```bash
/review                      # ブランチ全体の変更をレビュー（デフォルト）
/review --staged             # staged変更のみレビュー
/review --unstaged           # unstaged変更のみレビュー
/review --security           # セキュリティ観点のみ
/review path/to/script.sh    # 指定ファイルをレビュー
```

## Review Checklist

### Security

- [ ] ハードコードされた認証情報がない
- [ ] 機密情報は環境変数から取得している
- [ ] `eval` を使用していない
- [ ] 変数展開が適切にクォートされている

### Shell Best Practices

- [ ] shellcheckエラーがない
- [ ] `set -e` / `set -u` を使用している
- [ ] 変数は `"$var"` 形式でクォートされている
- [ ] コマンド置換は `$()` を使用している

### Compatibility

- [ ] Bash 3.2+ で動作する
- [ ] POSIX互換の構文を使用している

## Notes

- シェルスクリプト（.sh）は `shellcheck` を実行
- 大きな変更の場合は観点ごとに分けてレビュー

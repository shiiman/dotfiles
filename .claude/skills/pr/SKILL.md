---
name: pr
description: 現在のブランチからPull Requestを作成または更新する。ブランチ名から関連Issueを自動検出。
disable-model-invocation: true
allowed-tools: Read, Bash
argument-hint: "[タイトル] [--base <branch>|--draft]"
---

# Create Pull Request

現在のブランチからPull Requestを作成または更新する。

## Help

`$ARGUMENTS` に `--help` が含まれる場合、以下を表示して終了:

```text
/pr - Pull Request作成

概要:
  現在のブランチからPull Requestを作成または更新する。
  ブランチ名から関連Issueを自動検出。

使用方法:
  /pr [タイトル] [オプション]

オプション:
  --help           このヘルプを表示
  --base <branch>  宛先ブランチを指定（デフォルト: master）
  --draft          ドラフトPRとして作成

例:
  /pr                         # PRを作成
  /pr --draft                 # ドラフトPRを作成
  /pr "タイトル"               # タイトルを指定してPR作成
```

## Instructions

1. **引数の解析**:
   - `--base <branch>`: 宛先ブランチを指定（デフォルト: master）
   - `--draft`: ドラフトPRとして作成
   - その他の文字列: PRタイトルとして使用

2. **リポジトリ情報取得**:

   ```bash
   git remote get-url origin
   ```

   owner/repoを抽出

3. **デフォルトブランチ取得**:

   ```bash
   DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
   ```

4. **ブランチ状態確認**:

   ```bash
   # 未コミットの変更を確認
   git status --short

   # プッシュされていないコミットを確認
   CURRENT_BRANCH=$(git branch --show-current)
   git fetch origin
   git log origin/${CURRENT_BRANCH}..HEAD --oneline 2>/dev/null || echo "リモートブランチなし"
   ```

   - 未コミットの変更がある場合は警告
   - プッシュされていないコミットがある場合は警告

5. **変更内容の分析**:

   ```bash
   git diff origin/${DEFAULT_BRANCH}...HEAD --stat
   git log origin/${DEFAULT_BRANCH}..HEAD --pretty=format:"%s"
   ```

6. **PR種類の判定**:
   ブランチ名から自動判定:
   - `feature/*` → type/feature
   - `fix/*`, `bugfix/*` → type/bugfix
   - `docs/*` → type/docs
   - `refactor/*` → type/refactor
   - `chore/*` → type/chore

7. **関連Issue検出**:
   - ブランチ名から Issue 番号を抽出（例: `feature/123` → #123）
   - コミットメッセージから `#123` や `Closes #123` を検出

8. **PR本文生成**:

   ```markdown
   ## 概要

   [変更内容の要約]

   ## 主な変更点

   - [変更1]
   - [変更2]

   ## 関連Issue

   Closes #XX（あれば）
   ```

9. **PR作成**:

   ```bash
   gh pr create --title "タイトル" --body "本文" --base master
   # または --draft オプション付き
   gh pr create --title "タイトル" --body "本文" --base master --draft
   ```

10. **結果報告**:
    - PR URL
    - レビュー依頼の案内

## Usage

```bash
/pr                         # PRを作成
/pr --base main             # mainブランチ向けにPR作成
/pr --draft                 # ドラフトPRを作成
/pr "タイトル"               # タイトルを指定してPR作成
```

## Notes

- プッシュされていないコミットがある場合は先にプッシュを促す
- 未コミットの変更がある場合は先にコミットを促す

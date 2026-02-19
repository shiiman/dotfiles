---
name: setup
description: dotfilesの初期セットアップを実行する。シンボリックリンク作成、Homebrew、miseのセットアップを順番に実行。
disable-model-invocation: true
allowed-tools: Read, Bash
argument-hint: "[--skip-brew|--skip-mise|--check]"
---

# Project Setup

dotfilesの初期セットアップを実行する。新しいマシンでの環境構築に使用。

## Help

`$ARGUMENTS` に `--help` が含まれる場合、以下を表示して終了:

```text
/setup - dotfilesセットアップ

概要:
  dotfilesの初期セットアップを実行する。
  シンボリックリンク作成、Homebrew、miseのセットアップを順番に実行。

使用方法:
  /setup [オプション]

オプション:
  --help         このヘルプを表示
  --skip-brew    Homebrew関連をスキップ
  --skip-mise    miseセットアップをスキップ
  --check        現在の状態を確認するのみ

例:
  /setup                # 全ステップを実行
  /setup --skip-brew    # Homebrew関連をスキップ
  /setup --check        # 状態確認のみ
```

## Instructions

1. **現在の状態確認**:

   ```bash
   # シンボリックリンクの状態を確認
   ls -la ~/.bashrc ~/.zshrc ~/.gitconfig ~/.vimrc ~/.tmux.conf 2>/dev/null || echo "リンクなし"

   # Homebrewのインストール状態を確認
   which brew 2>/dev/null || echo "Homebrew未インストール"

   # miseのインストール状態を確認
   which mise 2>/dev/null || echo "mise未インストール"
   ```

2. **インストールステップの実行**:
   以下のコマンドを順番に実行し、各ステップの結果を報告:

   ```bash
   # Step 1: シンボリックリンク作成
   ./dotfile_setup.sh

   # Step 2: Homebrew パッケージインストール（--skip-brew でスキップ可）
   brew bundle --file=Brewfile

   # Step 3: mise セットアップ（--skip-mise でスキップ可）
   ./mise_setup.sh

   # Step 4: macOS 設定（オプション、確認後に実行）
   ./mac_setup.sh
   ```

3. **エラーハンドリング**:
   - 各ステップでエラーが発生した場合、エラー内容を報告し、続行するか確認
   - `--skip-brew` オプションがある場合、Step 2をスキップ
   - `--skip-mise` オプションがある場合、Step 3をスキップ

4. **結果報告**:
   - 成功したステップ一覧
   - 失敗したステップとエラー内容
   - 次のアクション

## Usage

```bash
/setup                    # 全ステップを実行
/setup --skip-brew        # Homebrew関連をスキップ
/setup --skip-mise        # miseセットアップをスキップ
/setup --check            # 現在の状態を確認するのみ
```

## Setup Steps

| Step | コマンド | 説明 |
|------|---------|------|
| 1 | `./dotfile_setup.sh` | シンボリックリンク作成 |
| 2 | `brew bundle` | Homebrewパッケージインストール |
| 3 | `./mise_setup.sh` | miseセットアップ |
| 4 | `./mac_setup.sh` | macOS設定（オプション） |

## Post-Setup

セットアップ完了後、以下を案内:

1. **シェルの再読み込み**:

   ```bash
   source ~/.zshrc  # または新しいターミナルを開く
   ```

2. **動作確認**:

   ```bash
   # シンボリックリンクの確認
   ls -la ~/.bashrc ~/.zshrc

   # Homebrewパッケージの確認
   brew list

   # miseの確認
   mise list
   ```

## Notes

- Homebrewがインストールされていない場合はインストール方法を案内
- Step 4（macOS設定）は確認後に実行（システム設定を変更するため）
- エラーが発生した場合は、エラーメッセージを確認して個別に対処

# dotfiles

macOS 開発環境の設定ファイル管理リポジトリ

## 管理対象ファイル

| ファイル            | 説明                  |
| ------------------- | --------------------- |
| `.bashrc`           | Bash設定              |
| `.zshrc`            | Zsh設定               |
| `.gitconfig`        | Git設定               |
| `.gitignore_global` | グローバルgitignore   |
| `.tmux.conf`        | tmux設定              |
| `.vimrc`            | Vim設定               |
| `mise/config.toml`  | mise グローバル設定   |
| `ghostty/config`    | Ghosttyターミナル設定 |

## ディレクトリ構成

```
dotfiles/
├── .bashrc
├── .zshrc
├── .gitconfig
├── .gitignore_global
├── .tmux.conf
├── .vimrc
├── Brewfile              # Homebrew パッケージ一覧
├── mac_setup.sh          # macOS 初期セットアップ
├── dotfile_setup.sh      # シンボリックリンク作成
├── mise_setup.sh         # mise セットアップ
├── ghostty_setup.sh      # Ghostty セットアップ
├── ai_setup.sh           # AIツール設定セットアップ
├── mise/
│   └── config.toml       # mise グローバル設定
├── ghostty/
│   └── config            # Ghosttyターミナル設定
├── ai/                   # AIツールグローバル設定
│   ├── claude/           # Claude Code
│   │   ├── settings.json     # 設定（モデル、権限、フック）
│   │   ├── CLAUDE.md         # グローバル指示
│   │   └── scripts/          # カスタムスクリプト
│   ├── cursor/           # Cursor
│   ├── codex/            # Codex
│   │   └── agents/       # Codexエージェント設定
│   └── antigravity/      # Antigravity
│       └── GEMINI.md     # Antigravityグローバル指示
├── iterm/                # iTerm2 設定ファイル
├── .claude/              # Claude Code プロジェクト設定
├── .cursor/              # Cursor プロジェクト設定
├── SublimeText/          # Sublime Text 設定
└── Fonts/                # フォントファイル
```

---

## macOS 初期セットアップ

新しい Mac をセットアップする場合：

### 1. App Store にログイン

mas (Mac App Store CLI) でアプリをインストールするため、先にログインしておく

### 2. GitHub Personal Access Token を設定（任意）

API レート制限を回避するため：

```bash
export HOMEBREW_GITHUB_API_TOKEN=ghp_YOUR_TOKEN_HERE
```

### 3. セットアップスクリプトを実行

```bash
curl -fsSL https://raw.githubusercontent.com/shiiman/dotfiles/master/mac_setup.sh -o mac_setup.sh && bash mac_setup.sh
```

このスクリプトは以下を実行します：

- Homebrew のインストール
- Brewfile からパッケージをインストール
- dotfile のシンボリックリンク作成
- mise のセットアップ（言語バージョン管理）
- fzf のインストール
- Sublime Text の設定（インストール済みの場合）
- Ghostty の設定（インストール済みの場合）
- AIツール設定（Claude Code, Cursor, Codex）
- Finder で隠しファイルを表示
- Ricty フォントのインストール（存在する場合）

### GTR (Git Worktree Runner)

`mac_setup.sh` 実行時に自動インストールされます。git worktree を効率的に管理するツールです。

---

## 個別セットアップ

### dotfile のみセットアップ

```bash
git clone https://github.com/shiiman/dotfiles.git ~/dotfiles
sh ~/dotfiles/dotfile_setup.sh
```

### mise セットアップ

各言語のバージョン管理ツール（Node.js, Python, Go, Terraform 等）をインストール：

```bash
sh ~/dotfiles/mise_setup.sh
```

### mise の使い方

```bash
# ツールのインストール
mise use node@20        # Node.js 20
mise use python@3.12    # Python 3.12
mise use go@1.22        # Go 1.22
mise use terraform@1.5  # Terraform 1.5
mise use terragrunt     # Terragrunt (最新)

# 一覧表示
mise ls                 # インストール済みツール
mise ls-remote node     # 利用可能なバージョン

# プロジェクト単位の管理
mise use node@20 --path  # .mise.toml に書き込み
```

### Ghostty セットアップ

Ghosttyターミナルの設定をセットアップ：

```bash
sh ~/dotfiles/ghostty_setup.sh
```

設定ファイルは `~/.config/ghostty/config` にシンボリックリンクされます。

### Homebrew パッケージ管理

```bash
# Brewfile からインストール
brew bundle

# 現在インストール済みのパッケージを Brewfile に出力
brew bundle dump --force
```

### AIツール設定セットアップ

Claude Code、Cursor、Codex、Antigravity のグローバル設定をセットアップ：

```bash
sh ~/dotfiles/ai_setup.sh
```

管理対象：

| ツール      | 設定ファイル                                                 | 説明                                 |
| ----------- | ------------------------------------------------------------ | ------------------------------------ |
| Claude Code | `~/.claude/settings.json`                                    | モデル、権限、フック設定             |
| Claude Code | `~/.claude/CLAUDE.md`                                        | グローバル指示（出力言語、ルール等） |
| Claude Code | `ai/claude/scripts/`                                         | カスタムスクリプト（statusline等）   |
| Claude Code | MCP: `multi-agent-mcp`                                       | マルチエージェント MCP サーバー      |
| Cursor      | `~/.cursor/mcp.json`                                         | MCPサーバー設定                      |
| Cursor      | `~/Library/Application Support/Cursor/User/settings.json`    | エディタ設定                         |
| Cursor      | `~/Library/Application Support/Cursor/User/keybindings.json` | キーバインド                         |
| Cursor      | `~/Library/Application Support/Cursor/User/snippets/`        | スニペット                           |
| Cursor      | `~/.cursor/extensions/extensions.json`                       | 拡張機能リスト                       |
| Codex       | `~/.codex/config.toml`                                       | CLI設定                              |
| Codex       | `~/.codex/skills/`                                           | スキル定義                           |
| Antigravity | `~/.gemini/GEMINI.md`                                        | グローバル指示（出力言語、ルール等） |
| Antigravity | `~/.antigravity/extensions/extensions.json`                  | 拡張機能リスト                       |

MCP サーバー `multi-agent-mcp` は `uvx` で GitHub から直接インストールされます（リポジトリの clone 不要）。

※ 既存ファイルは `~/.ai_config_backup/` にバックアップされます

---

## ドットファイル管理の手順

### 新しいファイルを追加する場合

1. 管理したいファイルを `~/dotfiles/` に移動
2. `dotfile_setup.sh` の `DOT_FILES` 配列に追加
3. シンボリックリンクを作成

```bash
mv ~/.newrc ~/dotfiles/
# dotfile_setup.sh を編集して .newrc を追加
sh ~/dotfiles/dotfile_setup.sh
```

### 変更を反映

```bash
cd ~/dotfiles
git add .
git commit -m "update dotfiles"
git push
```

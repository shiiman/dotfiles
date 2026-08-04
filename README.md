# dotfiles

macOS 開発環境の設定ファイル管理リポジトリ

## 管理対象ファイル

| ファイル                      | 説明                                      |
| ----------------------------- | ----------------------------------------- |
| `.bashrc`                     | Bash設定                                  |
| `.zshrc`                      | Zsh設定                                   |
| `.shellrc_common`             | Bash/Zsh 共通設定（alias・LANG・ls色）    |
| `.gitconfig`                  | Git設定                                   |
| `.gitignore_global`           | グローバルgitignore                       |
| `.tmux.conf`                  | tmux設定                                  |
| `.vimrc`                      | Vim設定                                   |
| `mise/config.toml`            | mise グローバル設定                       |
| `terminal/ghostty/config`     | ターミナル設定（cmux / Ghostty共用）      |
| `terminal/cmux/settings.json` | cmux 設定（~/.config/cmux/settings.json） |

### ローカル設定（追跡対象外）

このリポジトリは**公開**しているため、個人情報や業務固有の設定は追跡しない。
`dotfile_setup.sh` が雛形から生成する（既に存在する場合は変更しない）。

| ファイル             | 雛形                       | 用途                                     |
| -------------------- | -------------------------- | ---------------------------------------- |
| `~/.gitconfig.local` | `.gitconfig.local.example` | `user.name` / `user.email`               |
| `~/.shellrc_local`   | `.shellrc_local.example`   | 業務プロジェクトID・マシン固有の環境変数 |

`~/.gitconfig.local` は `.gitconfig` の `[include]` から、
`~/.shellrc_local` は `.shellrc_common` の末尾から読み込まれる。

## ディレクトリ構成

```
dotfiles/
├── .bashrc
├── .zshrc
├── .shellrc_common            # Bash/Zsh 共通設定
├── .gitconfig
├── .gitignore_global
├── .tmux.conf
├── .vimrc
├── .gitconfig.local.example   # ローカル設定の雛形
├── .shellrc_local.example     # ローカル設定の雛形
├── Brewfile                   # Homebrew パッケージ一覧
├── CLAUDE.md                  # AI指示（ai/rules/ から生成）
├── AGENTS.md                  # AI指示（ai/rules/ から生成）
├── GEMINI.md                  # AI指示（ai/rules/ から生成）
├── mac_setup.sh               # macOS 初期セットアップ
├── dotfile_setup.sh           # シンボリックリンク作成
├── mise_setup.sh              # mise セットアップ
├── terminal_setup.sh          # ターミナルセットアップ（cmux / Ghostty）
├── ai_setup.sh                # AIツール設定セットアップ
├── lib/
│   └── symlink.sh             # シンボリックリンク作成の共通処理
├── mise/
│   └── config.toml            # mise グローバル設定
├── terminal/
│   ├── ghostty/config         # ターミナル設定（cmux と共用）
│   ├── cmux/settings.json     # cmux 設定
│   └── iterm/                 # iTerm2 設定ファイル
├── ai/                        # AIツールグローバル設定
│   ├── rules/                 # AI指示ファイルの生成元
│   │   ├── common.md          # 共通ルール（全ツールに展開）
│   │   ├── claude.md          # Claude Code 固有
│   │   ├── codex.md           # Codex 固有
│   │   ├── gemini.md          # Gemini / Antigravity 固有
│   │   ├── cursor.md          # Cursor 固有
│   │   └── build.sh           # 生成スクリプト
│   ├── claude/
│   │   ├── settings.json      # モデル、権限、フック
│   │   ├── CLAUDE.md          # グローバル指示
│   │   └── scripts/           # statusline・プラグイン更新
│   ├── cursor/
│   │   ├── User/              # settings.json / keybindings.json / snippets
│   │   ├── mcp.json           # MCPサーバー設定
│   │   └── extensions.txt     # 拡張機能IDリスト
│   ├── vscode/
│   │   └── User/              # settings.json / keybindings.json
│   ├── codex/
│   │   ├── config.toml.template  # CLI設定の雛形（実ファイルは追跡しない）
│   │   ├── AGENTS.md          # グローバル指示
│   │   ├── skills/            # スキル定義
│   │   ├── lib/               # 共有ライブラリ
│   │   └── agents/            # agents定義
│   └── antigravity/
│       ├── GEMINI.md          # グローバル指示
│       └── extensions.txt     # 拡張機能IDリスト
├── .claude/                   # Claude Code プロジェクト設定
├── .cursor/rules/             # Cursor プロジェクト設定（ai/rules/ から生成）
├── .prettierrc                # Markdown整形設定
├── .shellcheckrc              # shellcheck設定
└── package.json               # Prettier (Markdown整形)
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
curl -fsSL https://raw.githubusercontent.com/shiiman/dotfiles/main/mac_setup.sh -o mac_setup.sh && bash mac_setup.sh
```

このスクリプトは以下を実行します：

- Homebrew のインストール
- Brewfile からパッケージをインストール
- dotfile のシンボリックリンク作成（ローカル設定の雛形生成を含む）
- mise のセットアップ（言語バージョン管理）
- fzf のインストール
- ターミナル設定（cmux / Ghostty、インストール済みの場合）
- AIツール設定（Claude Code, Cursor, VSCode, Codex, Antigravity）
- GTR (Git Worktree Runner) のインストール
- Finder で隠しファイルを表示

ターミナル用フォント（Ricty Diminished）は Brewfile の `cask "font-ricty-diminished"` で入る。

### GTR (Git Worktree Runner)

`mac_setup.sh` 実行時に自動インストールされます。git worktree を効率的に管理するツールです。

---

## 個別セットアップ

### dotfile のみセットアップ

```bash
git clone https://github.com/shiiman/dotfiles.git ~/dotfiles
bash ~/dotfiles/dotfile_setup.sh
```

### mise セットアップ

各言語のバージョン管理ツール（Node.js, Python, Go, Terraform 等）をインストール：

```bash
bash ~/dotfiles/mise_setup.sh
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

### ターミナルセットアップ

cmux / Ghostty ターミナルの設定をセットアップ：

```bash
bash ~/dotfiles/terminal_setup.sh
```

以下の設定ファイルがシンボリックリンクされます：

- Ghostty: `~/.config/ghostty/config`（cmux と共用）
- cmux: `~/.config/cmux/settings.json`

### Homebrew パッケージ管理

```bash
# Brewfile からインストール
brew bundle

# 差分の確認（未インストール／未記載を洗い出す）
brew bundle check --verbose

# 現在インストール済みのパッケージを Brewfile に出力
brew bundle dump --force
```

`brew bundle dump --force` は Brewfile のコメントを消すため、実行後はコメントを復元する。

### AIツール設定セットアップ

Claude Code、Cursor、VSCode、Codex、Antigravity のグローバル設定をセットアップ：

```bash
bash ~/dotfiles/ai_setup.sh
```

管理対象：

| ツール      | 配置先                                                       | 方式    | 説明                     |
| ----------- | ------------------------------------------------------------ | ------- | ------------------------ |
| Claude Code | `~/.claude/settings.json`                                    | symlink | モデル、権限、フック設定 |
| Claude Code | `~/.claude/CLAUDE.md`                                        | symlink | グローバル指示           |
| Claude Code | `ai/claude/scripts/`                                         | -       | statusline等のスクリプト |
| Claude Code | MCP: `multi-agent-mcp` / `notebooklm-mcp`                    | -       | MCP サーバー             |
| Cursor      | `~/.cursor/mcp.json`                                         | symlink | MCPサーバー設定          |
| Cursor      | `~/Library/Application Support/Cursor/User/settings.json`    | symlink | エディタ設定             |
| Cursor      | `~/Library/Application Support/Cursor/User/keybindings.json` | symlink | キーバインド             |
| Cursor      | `~/Library/Application Support/Cursor/User/snippets/`        | symlink | スニペット               |
| Cursor      | `ai/cursor/extensions.txt`                                   | -       | 拡張機能IDリスト         |
| VSCode      | `~/Library/Application Support/Code/User/settings.json`      | symlink | エディタ設定             |
| VSCode      | `~/Library/Application Support/Code/User/keybindings.json`   | symlink | キーバインド             |
| Codex       | `~/.codex/config.toml`                                       | コピー  | CLI設定（雛形から生成）  |
| Codex       | `~/.codex/AGENTS.md`                                         | symlink | グローバル指示           |
| Codex       | `~/.codex/skills/`                                           | symlink | スキル定義               |
| Codex       | `~/.codex/lib/`                                              | symlink | 共有ライブラリ           |
| Codex       | `~/.codex/agents/`                                           | symlink | agents定義               |
| Antigravity | `~/.gemini/GEMINI.md`                                        | symlink | グローバル指示           |
| Antigravity | `ai/antigravity/extensions.txt`                              | -       | 拡張機能IDリスト         |

MCP サーバーは `uvx` で GitHub から直接インストールされます（リポジトリの clone 不要）。

※ 既存ファイルは `~/.ai_config_backup/` にバックアップされます

#### ツールが自動書き換えするファイルは追跡しない

一部の CLI / エディタは自分の設定ファイルを実行時に書き換える。
symlink にすると絶対パスや作業中プロジェクト名がリポジトリへ流入し、
作業ツリーも常に dirty になるため、以下は追跡対象から外している。

| ファイル                         | 追跡するもの               | 書き換える主体 |
| -------------------------------- | -------------------------- | -------------- |
| `ai/codex/config.toml`           | `config.toml.template`     | Codex CLI      |
| `ai/cursor/extensions.json`      | `extensions.txt`（IDのみ） | Cursor         |
| `ai/antigravity/extensions.json` | `extensions.txt`（IDのみ） | Antigravity    |

設定変更を dotfiles に残す場合は、雛形（`*.template` / `extensions.txt`）を更新する。

---

## 開発

### Markdown整形

```bash
npm install                 # 初回のみ
npm run format              # 全 .md を Prettier で整形
npm run format:check        # チェックのみ（書き換えない）
```

`.md` を作成・編集したら、コミット前に `npm run format` を実行する。

### シェルスクリプトのlint

```bash
shellcheck *.sh lib/*.sh ai/rules/*.sh
/lint                       # Claude Code / Cursor のスラッシュコマンド
```

`.shellcheckrc` で `external-sources=true` を設定しているため、
`source` した `lib/symlink.sh` も解析される。

### AI指示ファイルの再生成

`CLAUDE.md` / `AGENTS.md` / `GEMINI.md` / `.cursor/rules/CURSOR.mdc` は
`ai/rules/` から生成される。**直接編集しない。**

```bash
# 共通ルールを変更する場合
vim ai/rules/common.md
bash ai/rules/build.sh

# ツール固有ルールを変更する場合
vim ai/rules/claude.md      # claude / codex / gemini / cursor
bash ai/rules/build.sh
```

### gitignore の役割分担

| ファイル            | 役割                                                                 |
| ------------------- | -------------------------------------------------------------------- |
| `.gitignore`        | **このリポジトリ固有**の除外（ローカル設定・ツールの自動生成物など） |
| `.gitignore_global` | **全リポジトリ共通**の除外（OS・エディタ・言語の生成物）             |

`.gitignore_global` はこのリポジトリが配布するファイルであり、
`dotfile_setup.sh` を実行するまで有効にならない。
そのため clone 直後の誤コミットを防ぐ目的で、
ローカル固有ファイルは `.gitignore` にも明記している。

---

## ドットファイル管理の手順

### 新しいファイルを追加する場合

1. 管理したいファイルを `~/dotfiles/` に移動
2. `dotfile_setup.sh` の `DOT_FILES` 配列に追加
3. シンボリックリンクを作成

```bash
mv ~/.newrc ~/dotfiles/
# dotfile_setup.sh を編集して .newrc を追加
bash ~/dotfiles/dotfile_setup.sh
```

リンク元が存在しない場合、`dotfile_setup.sh` は警告を出してスキップする
（壊れたシンボリックリンクを作らない）。

### 変更を反映

```bash
cd ~/dotfiles
git add .
git commit -m "update dotfiles"
git push
```

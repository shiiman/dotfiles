# dotfiles

macOS 開発環境の設定ファイル管理リポジトリ

## 管理対象ファイル

| ファイル | 説明 |
|---------|------|
| `.bashrc` | Bash設定 |
| `.zshrc` | Zsh設定 |
| `.gitconfig` | Git設定 |
| `.gitignore_global` | グローバルgitignore |
| `.tmux.conf` | tmux設定 |
| `.vimrc` | Vim設定 |
| `mise/config.toml` | mise グローバル設定 |

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
├── mise/
│   └── config.toml       # mise グローバル設定
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
- Finder で隠しファイルを表示
- Ricty フォントのインストール（存在する場合）

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

### Homebrew パッケージ管理

```bash
# Brewfile からインストール
brew bundle

# 現在インストール済みのパッケージを Brewfile に出力
brew bundle dump --force
```

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

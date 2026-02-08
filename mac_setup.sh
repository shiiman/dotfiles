#!/bin/bash
set -e

# Homebrewのインストール.
if ! type brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # パスを明示的に通す
    if [ -d /opt/homebrew/bin ]; then
        export PATH="/opt/homebrew/bin:$PATH"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -d /usr/local/bin ]; then
        export PATH="/usr/local/bin:$PATH"
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# brewコマンドが本当に使えるか再確認
if ! type brew >/dev/null 2>&1; then
    echo "brewコマンドが見つかりません。Homebrewのインストール後、再度このスクリプトを実行してください。"
    exit 1
fi

# GitHubから設定ファイルをclone.
if ! type git >/dev/null 2>&1; then
    brew install git
fi
if [ ! -d ~/dotfiles ]; then
    git clone https://github.com/shiiman/dotfiles.git ~/dotfiles
else
    echo "~/dotfiles already exists. Pulling latest changes..."
    cd ~/dotfiles && git pull
fi

# 設定ファイルフォルダに移動.
cd ~/dotfiles || { echo "Failed to cd to ~/dotfiles"; exit 1; }
# ローカルリポジトリにユーザのメールアドレス登録.
git config user.email hsnonsense5@gmail.com

# アプリインストール（事前にsudo認証をキャッシュ）
sudo -v
brew bundle

##################################################################

# dotfileの設定.
bash ~/dotfiles/dotfile_setup.sh

# Vimのundo永続化用ディレクトリを作成
mkdir -p ~/.vim/undo

# デフォルトシェルをzshに変更（パスワード入力が必要）
if [ "$SHELL" != "/bin/zsh" ]; then
    echo "デフォルトシェルをzshに変更します（パスワードが必要です）"
    chsh -s /bin/zsh
fi

# miseの設定 (言語バージョン管理)
bash ~/dotfiles/mise_setup.sh

# fzfをインストール.
if [ -f /opt/homebrew/opt/fzf/install ]; then
    /opt/homebrew/opt/fzf/install --all
elif [ -f /usr/local/opt/fzf/install ]; then
    /usr/local/opt/fzf/install --all
fi

# sublime textの設定.
if [ -d "/Applications/Sublime Text.app" ]; then
    open -a "Sublime Text"
    sleep 10 # 起動待ち
    bash ~/dotfiles/SublimeText/sublime_setup.sh
fi

# Ghosttyの設定
bash ~/dotfiles/ghostty_setup.sh

# AIツール設定（Claude Code, Cursor, Codex）
bash ~/dotfiles/ai_setup.sh

# GTR (Git Worktree Runner) のインストール
if [ ! -d ~/git-worktree-runner ]; then
    echo "GTR (Git Worktree Runner) をインストール中..."
    git clone https://github.com/coderabbitai/git-worktree-runner.git ~/git-worktree-runner
    (cd ~/git-worktree-runner && ./install.sh)
else
    echo "GTR は既にインストールされています。最新版に更新中..."
    (cd ~/git-worktree-runner && git pull && ./install.sh)
fi

# finderで隠しファイルの表示.
defaults write com.apple.finder AppleShowAllFiles -bool true
killall Finder

##################################################################

# フォントの設定.
if [ -d ~/dotfiles/Fonts ] && ls ~/dotfiles/Fonts/Ricty*.ttf >/dev/null 2>&1; then
    cp -f ~/dotfiles/Fonts/Ricty*.ttf ~/Library/Fonts/
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -fv
    fi
fi

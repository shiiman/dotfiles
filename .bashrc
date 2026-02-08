# pathを設定
export PATH="$HOME/bin:/usr/local/bin:/opt/homebrew/bin:$HOME/pear/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc' ]; then source '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc' ]; then source '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'; fi

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# mise - 言語バージョン管理
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
fi

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

###########################################################
# itermの設定                                              #
###########################################################

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

###########################################################
# fzfの設定                                                #
###########################################################

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

###########################################################
# gitの設定                                                #
###########################################################
# 補完読み込み
[ -f /opt/homebrew/opt/git/etc/bash_completion.d/git-completion.bash ] && source /opt/homebrew/opt/git/etc/bash_completion.d/git-completion.bash
[ -f /opt/homebrew/opt/git-flow/etc/bash_completion.d/git-flow-completion.bash ] && source /opt/homebrew/opt/git-flow/etc/bash_completion.d/git-flow-completion.bash

###########################################################
#  lsの設定                                                #
###########################################################
# lsコマンド時、自動で色がつく
export CLICOLOR=1
# 色の設定
export LSCOLORS='exfxcxdxbxegedabagacad'
# 補完時の色の設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

###########################################################
#  aliasの設定                                             #
###########################################################
# history にコマンド実行時刻を記録する
HISTTIMEFORMAT='%Y-%m-%d '

# grepでヒットした文字列強調
alias grep="grep --color"

alias cp='cp -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias mv='mv -i -v'

alias ..='cd ../'
alias ...='cd ../..'
alias ....='cd ../../..'

alias ll='ls -l'
alias la='ls -a'

# cdの後にlsとpwdを実行
function cdlspwd() {
    builtin cd "${1:-$HOME}" && la && pwd
}
alias cd=cdlspwd

if type vim >/dev/null 2>&1; then
    alias vi='vim'
fi

alias k='kubectl'

# GTR (Git Worktree Runner) - git worktree管理ツール
alias gwr='git gtr'

# helm補完
if type helm >/dev/null 2>&1; then
    eval "$(helm completion bash)" >/dev/null 2>&1
fi

###########################################################
#  ヒストリーの設定                                          #
###########################################################
# ヒストリを保存するファイル指定
HISTFILE=~/.bash_history
# メモリに保存されるヒストリの件数
HISTSIZE=10000
# 保存されるヒストリの件数
HISTFILESIZE=10000
# 重複・空白開始コマンドを除外
HISTCONTROL=ignoreboth:erasedups
# ヒストリを上書きせず追記
shopt -s histappend

###########################################################
#  シェルオプションの設定                                    #
###########################################################
# ** でサブディレクトリも再帰マッチ
shopt -s globstar
# cdのtypoを自動修正
shopt -s cdspell
# ディレクトリ名補完時のtypo修正
shopt -s dirspell

###########################################################
#  その他の設定                                             #
###########################################################
# 文字コードをUTF-8に設定
export LANG=ja_JP.UTF-8

# プロンプト設定
PS1="[\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;36m\]\h\[\e[0m\] ~]$ "

# direnv - プロジェクト固有の環境変数自動設定
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

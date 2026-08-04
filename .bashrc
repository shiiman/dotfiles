# pathを設定
export PATH="$HOME/bin:/usr/local/bin:/opt/homebrew/bin:$HOME/pear/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"

###########################################################
# 共通設定の読み込み (bash/zsh 共用)                        #
###########################################################
# LANG / LS_COLORS / alias を定義する。
# bash は関数定義の読み込み時に alias を展開するため、
# alias を参照する関数より前で読み込む必要がある。
if [ -f ~/.shellrc_common ]; then
    source ~/.shellrc_common
else
    echo "警告: ~/.shellrc_common が見つかりません。~/dotfiles/dotfile_setup.sh を実行してください。" >&2
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.bash.inc' ]; then source '/opt/homebrew/share/google-cloud-sdk/path.bash.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.bash.inc' ]; then source '/opt/homebrew/share/google-cloud-sdk/completion.bash.inc'; fi

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
#  aliasの設定                                             #
###########################################################
# history にコマンド実行時刻を記録する
HISTTIMEFORMAT='%Y-%m-%d '

alias ..='cd ../'

# cdの後にlsとpwdを実行
# alias(la)ではなく実コマンドを直接使う:
# bashは関数定義の読み込み時にaliasを展開するため、alias依存は読み込み順に壊れやすい
function cdlspwd() {
    builtin cd "${1:-$HOME}" && ls -a && pwd
}
alias cd=cdlspwd

# helm補完
if type helm >/dev/null 2>&1; then
    eval "$(helm completion bash)" >/dev/null 2>&1
fi

###########################################################
#  ヒストリーの設定                                          #
###########################################################
# ヒストリを保存するファイル指定
HISTFILE=~/.bash_history
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
# プロンプト設定
PS1="[\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;36m\]\h\[\e[0m\] ~]$ "

# PATH の重複排除
PATH=$(printf '%s' "$PATH" | awk -v RS=: '!seen[$0]++ {if (NR>1) printf ":"; printf $0}')
export PATH

# direnv - プロジェクト固有の環境変数自動設定
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

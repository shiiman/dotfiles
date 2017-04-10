# pathを設定
path=(~/bin /usr/local/bin ~/pear/bin ${path})
export XDG_CONFIG_HOME=~/.config

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc' ]; then source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc' ]; then source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'; fi


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
[ -f /usr/local/opt/git/etc/bash_completion.d/git-completion.bash ] && source /usr/local/opt/git/etc/bash_completion.d/git-completion.bash
[ -f /usr/local/opt/git-flow/etc/bash_completion.d/git-flow-completion.bash ] && source /usr/local/opt/git-flow/etc/bash_completion.d/git-flow-completion.bash


###########################################################
#  lsの設定                                                #
###########################################################
# lsコマンド時、自動で色がつく
export CLICOLOR=true
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
    # cdがaliasでループするので\をつける
    \cd $1;
    la;
    pwd;
}
alias cd=cdlspwd

if type nvim >/dev/null 2>&1; then
    alias vi='nvim'
fi

if type ag >/dev/null 2>&1; then
    alias grep='ag'
fi


###########################################################
#  ヒストリーの設定                                          #
###########################################################
# ヒストリを保存するファイル指定
HISTFILE=~/.bash_history
# メモリに保存されるヒストリの件数
HISTSIZE=10000
# 保存されるヒストリの件数
SAVEHIST=10000


###########################################################
#  その他の設定                                             #
###########################################################
# 文字コードをUTF-8に設定
export LANG=ja_JP.UTF-8

# 区切り文字の設定
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# プロンプト設定
PS1="[\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;36m\]\h\[\e[0m\]] % "


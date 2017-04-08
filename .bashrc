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
# grepでヒットした文字列強調
alias grep="grep --color"

alias cp='cp -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias mv='mv -i -v'

alias ...='cd ../..'
alias ....='cd ../../..'

alias ll='ls -l'
alias la='ls -a'

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
HISTFILE=~/.zsh_history
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

PS1="[\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;36m\]\h\[\e[0m\]] % "


# pathを設定（/opt/homebrew/bin, /opt/homebrew/sbin は brew shellenv で設定）
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/pear/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"

if [ -e "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
fpath=(~/.zsh/completion $fpath)

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# mise - 言語バージョン管理 (anyenv/asdfの後継)
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

###########################################################
# zinitの設定                                              #
###########################################################

### Added by Zinit's installer
# zinit のパス（新旧両方に対応）
if [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
elif [[ -f "$HOME/.zinit/bin/zinit.zsh" ]]; then
    source "$HOME/.zinit/bin/zinit.zsh"
fi
autoload -Uz _zinit
if typeset -p _comps >/dev/null 2>&1; then
    _comps[zinit]=_zinit
fi

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
# 非推奨の可能性があるためコメントアウト
# zinit light-mode zdharma-continuum/zinit-annex-as-monitor

### End of Zinit's installer chunk

# プラグインのインストール.
zinit light "zsh-users/zsh-autosuggestions"
zinit light "zsh-users/zsh-completions"
zinit light "zdharma-continuum/history-search-multi-word"
zinit light 'chrissicool/zsh-256color'

zinit ice wait'1' lucid
zinit light "zdharma-continuum/fast-syntax-highlighting"

###########################################################
# itermの設定                                              #
###########################################################

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

###########################################################
# fzfの設定                                                #
###########################################################

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

###########################################################
#  lsの設定                                                #
###########################################################
# ZLS_COLORS設定（CLICOLOR, LSCOLORS, LS_COLORS は .shellrc_common で設定）
export ZLS_COLORS=$LS_COLORS

###########################################################
#  cdの設定                                               #
###########################################################
# ディレクトリ名の入力のみで移動する
setopt auto_cd
# cdした先のディレクトリをディレクトリスタックに追加する
setopt auto_pushd
# pushd したとき、ディレクトリがすでにスタックに含まれていればスタックに追加しない
setopt pushd_ignore_dups
# コマンドのtypo修正提案
setopt correct

# ディレクトリ移動時の表示（ファイル数が多い場合は省略）
function chpwd() {
    if [[ $(ls -1 | wc -l) -lt 50 ]]; then
        ls -a
    fi
    pwd
}

###########################################################
#  aliasの設定                                             #
###########################################################
# historyに日付を表示
alias history='fc -lt "%F %T" 1'

###########################################################
#  グロブの設定                                             #
###########################################################
# 大文字小文字区別
setopt case_glob
# 「= コマンド」を絶対パスの展開
setopt equals
# 拡張ブロブを使用する
setopt extended_glob
# ファイルグロブ機能を使用する
setopt glob
# .で始まるファイルもマッチ
setopt glob_dots
# 数値ソート
setopt numeric_glob_sort

###########################################################
#  ヒストリーの設定                                          #
###########################################################
# ヒストリを保存するファイル指定
HISTFILE=~/.zsh_history
# 保存されるヒストリの件数
SAVEHIST=10000

# ヒストリに実行時間も保存する
setopt extended_history
# 直前と同じコマンドはヒストリに追加しない
setopt hist_ignore_dups
# ヒストリーに重複を表示しない
setopt hist_ignore_all_dups
# コマンドがスペースで始まる場合、コマンド履歴に追加しない
setopt hist_ignore_space
# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks
# historyコマンドは履歴に登録しない
setopt hist_no_store

# 他のターミナルとヒストリーを共有
setopt share_history

###########################################################
#  補完の設定                                               #
###########################################################
# 補完機能を有効にする
autoload -Uz compinit compdef
compinit -C

# ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash
# ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt mark_dirs
# 補完候補を一覧で表示する
setopt auto_list
# 補完キー連打で補完候補を順に表示する
setopt auto_menu
# カッコの対応などを自動的に補完
setopt auto_param_keys
# 補完候補をできるだけ詰めて表示する
setopt list_packed
# 補完候補にファイルの種類も表示する
setopt list_types
# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst
# 語の途中でもカーソル位置で補完
setopt complete_in_word
# カーソル位置は保持したままファイル名一覧を順次その場で表示
setopt always_last_prompt

# 補完後、メニュー選択モードになり左右キーで移動が出来る
zstyle ':completion:*:default' menu select=2
# 補完で大文字にもマッチ
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補に色を付ける
zstyle ':completion:*:default' list-colors "${LS_COLORS}"
# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'
# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /opt/homebrew/bin \
    /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# Shift-Tabで補完候補を逆順する("\e[Z"でも動作する)
bindkey "^[[Z" reverse-menu-complete

# 補完を絞り込み
bindkey "^p" history-beginning-search-backward
bindkey "^n" history-beginning-search-forward

# helm補完
if type helm >/dev/null 2>&1; then
    source <(helm completion zsh) >&/dev/null
fi

###########################################################
#  プロンプトの設定                                         #
###########################################################
# プロンプトに色を付ける
autoload -Uz colors
colors

# プロンプト 右にカレントディレクトリと時刻を表示
PROMPT="[%(?.%{${fg[green]}%}.%{${fg[red]}%})%n%{${reset_color}%}@%{${fg[blue]}%}%m%{${reset_color}%} ~]$ "
RPROMPT="[%{${fg[green]}%}%*%{${reset_color}%}]"

# kube-ps1
if [ -e "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh" ]; then
    source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
    PS1='$(kube_ps1)'$PS1
    kubeoff
fi

###########################################################
#  gitの設定                                               #
###########################################################
# vcs_infoロード
autoload -Uz vcs_info
# PROMPT変数内で変数参照する
setopt prompt_subst

# vcsの表示
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{green}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "[%F{blue}%c%u%b%f]"
zstyle ':vcs_info:*' actionformats '[%b|%a]'

# プロンプト表示直前にvcs_info呼び出し
autoload -Uz add-zsh-hook
add-zsh-hook precmd vcs_info
# プロンプト表示
RPROMPT='${vcs_info_msg_0_}'$RPROMPT

###########################################################
#  その他の設定                                             #
###########################################################
# 各変数の重複を自動削除
typeset -U path cdpath fpath manpath

# 文字コードをUTF-8に設定（LANG は .shellrc_common で設定）
# 日本語ファイル名等8ビットを通す
setopt print_eight_bit

# Ctrl+sのロック, Ctrl+qのロック解除を無効にする
setopt no_flow_control
# ctrl -Dでログアウトさせない
setopt IGNOREEOF

# ビープを無効にする
setopt no_beep
setopt no_hist_beep
setopt no_list_beep

# rm * の前に確認をとる
setopt rm_star_wait

# URLをエスケープする
autoload -Uz url-quote-magic
# 文字入力時にURLをエスケープする
zle -N self-insert url-quote-magic

# jobsでプロセスIDも出力する。
setopt long_list_jobs
# バックグラウンドジョブの状態変化を即時報告する
setopt notify
# zsh終了時にbgジョブや一時停止中のジョブが表示される
setopt check_jobs

# 区切り文字の設定
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# リダイレクトによる上書き禁止 「>!」で上書きできる
setopt noclobber

# キーバインド無効
bindkey -r '^J'
bindkey -r '^O'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

# Added by Antigravity
[[ -d "${HOME}/.antigravity/antigravity/bin" ]] && export PATH="${HOME}/.antigravity/antigravity/bin:$PATH"

# 共通設定の読み込み
[ -f ~/.shellrc_common ] && source ~/.shellrc_common

# direnv - プロジェクト固有の環境変数自動設定
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

# added by Snowflake SnowSQL installer v1.2
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH

export GOOGLE_CLOUD_PROJECT="szp-ai"
export GOOGLE_CLOUD_LOCATION="us-central1"
export GOOGLE_GENAI_USE_VERTEXAI=true

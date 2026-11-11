# pathを設定（/opt/homebrew/bin, /opt/homebrew/sbin は brew shellenv で設定）
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"

###########################################################
# 共通設定の読み込み (bash/zsh 共用)                        #
###########################################################
# LANG / LS_COLORS / alias を定義する。
# 後続の ZLS_COLORS と補完の list-colors が LS_COLORS を参照するため、
# 必ず参照箇所より前で読み込む。
if [ -f ~/.shellrc_common ]; then
    source ~/.shellrc_common
else
    print -u2 "警告: ~/.shellrc_common が見つかりません。~/dotfiles/dotfile_setup.sh を実行してください。"
fi

# brew shellenv は起動のたびに約1.5秒かかるため、同じ出力を直接設定する。
# (出力が変わった場合は `brew shellenv` と見比べて更新する)
if [ -e "/opt/homebrew/bin/brew" ]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    fpath[1,0]="/opt/homebrew/share/zsh/site-functions"
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
    [ -z "${MANPATH-}" ] || { export MANPATH="${MANPATH%"${MANPATH##*[!:]}"}"; export MANPATH=":${MANPATH#"${MANPATH%%[!:]*}"}"; }
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
fi
fpath=(~/.zsh/completion $fpath)

# コマンドの出力をキャッシュして source する(起動時のプロセス起動を減らす)。
# コマンド実体のパス(Homebrew では Cellar のバージョン入り)が変わったときだけ再生成する。
# 使い方: _cached_source <キャッシュ名> <コマンド> [引数...]
_cached_source() {
    local name=$1; shift
    local bin=${commands[$1]}
    [[ -n $bin ]] || return 0
    local real=${bin:A}
    local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$name.zsh
    local first=
    [[ -s $cache ]] && read -r first < $cache
    if [[ $first != "# $real" ]]; then
        mkdir -p ${cache:h} || return 0
        if "$@" >| $cache.tmp 2>/dev/null; then
            { print -r -- "# $real"; cat $cache.tmp } >| $cache
        fi
        rm -f $cache.tmp
    fi
    [[ -s $cache ]] && source $cache
}

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# direnv - プロジェクト固有の環境変数自動設定
# mise activate より先に direnv export を実行し、MISE_DATA_DIR 等を反映させる
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv export zsh 2>/dev/null)"
    _cached_source direnv-hook direnv hook zsh
fi

# mise - 言語バージョン管理 (anyenv/asdfの後継)
if command -v mise >/dev/null 2>&1; then
    _cached_source mise-activate mise activate zsh
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
    # 非表示ファイルを除いた件数を、外部コマンドなしで数える(ls | wc の起動を避ける)
    # 呼び出し元のシェル設定(bare_glob_qual 等)に依存しないよう、必要なオプションを明示する
    setopt local_options no_glob_dots null_glob
    local -a entries
    entries=(*)
    if (( $#entries < 50 )); then
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
    _cached_source helm-completion helm completion zsh >&/dev/null
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
# PROMPT変数内で変数参照する
setopt prompt_subst

# プロンプトの git 表示。vcs_info は check-for-changes で git を7回起動し、
# プロンプトのたびに1秒以上かかるため、git を1回だけ呼ぶ自前の関数に置き換えた。
# 表示: [ブランチ名] / ステージ済みは緑の !、未ステージは赤の +(untracked は見ない)
# rebase / merge 等の途中は [ブランチ名|状態]。状態は .git 内のファイルから判定する(git 起動なし)。
_prompt_git_action() {
    REPLY=
    local d=$PWD gd= l
    while [[ -n $d ]]; do
        if [[ -d $d/.git ]]; then
            gd=$d/.git; break
        elif [[ -f $d/.git ]]; then
            read -r l < $d/.git
            gd=${l#gitdir: }
            [[ $gd == /* ]] || gd=$d/$gd
            break
        fi
        d=${d%/*}
    done
    [[ -n $gd ]] || return 0
    if [[ -d $gd/rebase-merge || -d $gd/rebase-apply ]]; then REPLY=rebase
    elif [[ -f $gd/MERGE_HEAD ]]; then REPLY=merge
    elif [[ -f $gd/CHERRY_PICK_HEAD ]]; then REPLY=cherry-pick
    elif [[ -f $gd/REVERT_HEAD ]]; then REPLY=revert
    elif [[ -f $gd/BISECT_LOG ]]; then REPLY=bisect
    fi
}

_prompt_git_info() {
    _git_prompt_info=
    local out line oid= branch= staged= unstaged= xy
    out=$(GIT_OPTIONAL_LOCKS=0 command git status -b --porcelain=v2 -uno 2>/dev/null) || return 0
    for line in "${(@f)out}"; do
        case $line in
            '# branch.oid '*)  oid=${line#'# branch.oid '} ;;
            '# branch.head '*) branch=${line#'# branch.head '} ;;
            'u '*) unstaged=1 ;;
            [12]' '*)
                xy=${line[3,4]}
                [[ ${xy[1]} != . ]] && staged=1
                [[ ${xy[2]} != . ]] && unstaged=1
                ;;
        esac
    done
    [[ -n $branch ]] || return 0
    [[ $branch == '(detached)' ]] && branch=${oid[1,7]}
    branch=${branch//\%/%%}
    _prompt_git_action
    if [[ -n $REPLY ]]; then
        _git_prompt_info="[${branch}|${REPLY}]"
    else
        _git_prompt_info="[%F{blue}${staged:+%F{green\}!}${unstaged:+%F{red\}+}${branch}%f]"
    fi
}

# プロンプト表示直前に git 情報を更新
autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_git_info
# プロンプト表示
RPROMPT='${_git_prompt_info}'$RPROMPT

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
# 誤爆より利便性を優先して無効化している
# setopt noclobber

# キーバインド無効
bindkey -r '^J'
bindkey -r '^O'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

# Added by Antigravity
[[ -d "${HOME}/.antigravity/antigravity/bin" ]] && export PATH="${HOME}/.antigravity/antigravity/bin:$PATH"

# added by Snowflake SnowSQL installer v1.2
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH

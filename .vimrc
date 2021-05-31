"######################################################################################
"# vimの設定                                                                           #
"######################################################################################
"###########################################################
"# 画面表示の設定                                             #
"###########################################################
" 編集中のファイル名を表示
set title
" 行番号を表示
set number
" 現在の行を強調表示
set cursorline
" ステータス行を常に表示
set laststatus=2
" メッセージ表示欄を2行確保
set cmdheight=2
" 対応括弧に<と>のペアを追加
set matchpairs& matchpairs+=<:>
" 対応する括弧を強調表示
set showmatch
" 入力中のコマンドをステータスに表示する
set showcmd
" ヘルプを画面いっぱいに開く
set helpheight=999
" 不可視文字を表示
set list
" 不可視文字の表示記号指定
set listchars=tab:»-,eol:↲,extends:»,precedes:«
"  入力されているテキストの最大幅。0の場合無効。
set textwidth=0
" カーソルが何行目の何列目に置かれているかを表示する。
set ruler
" 折り返ししない
set nowrap


""""""""""""""""""""""""""""""
" 全角スペースの表示
""""""""""""""""""""""""""""""
function! ZenkakuSpace()
    highlight ZenkakuSpace ctermfg=darkred ctermbg=darkred
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme * call ZenkakuSpace()
        autocmd VimEnter,WinEnter,BufRead * let w:m1=matchadd('ZenkakuSpace', '　')
    augroup END
    call ZenkakuSpace()
endif
""""""""""""""""""""""""""""""

"###########################################################
"# タブの設定                                                #
"###########################################################
" Anywhere SID.
function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

 " 常にタブラインを表示
set showtabline=2

" tabline設定
function! s:my_tabline()
  let s = ''
  for i in range(1, tabpagenr('$'))
    let bufnrs = tabpagebuflist(i)
    let bufnr = bufnrs[tabpagewinnr(i) - 1]
    let no = i
    let mod = getbufvar(bufnr, '&modified') ? '!' : ' '
    let title = fnamemodify(bufname(bufnr), ':t')
    let title = '[' . title . ']'
    let s .= '%'.i.'T'
    let s .= '%#' . (i == tabpagenr() ? 'TabLineSel' : 'TabLine') . '#'
    let s .= no . ':' . title
    let s .= mod
    let s .= '%#TabLineFill# '
  endfor
  let s .= '%#TabLineFill#%T%=%#TabLine#'
  return s
endfunction

let &tabline = '%!'. s:SID_PREFIX() . 'my_tabline()'

" キーマップ設定
nnoremap    [Tag]   <Nop>
nmap    t [Tag]

" t1 で1番左のタブ、t2 で1番左から2番目のタブにジャンプ
for n in range(1, 9)
  execute 'nnoremap <silent> [Tag]'.n  ':<C-u>tabnext'.n.'<CR>'
endfor

" tn 新しいタブを一番右に作る
map <silent> [Tag]n :tablast <bar> tabnew<CR>
" tw タブを閉じる
map <silent> [Tag]w :tabclose<CR>
" tl 次のタブ
map <silent> [Tag]l :tabnext<CR>
" th 前のタブ
map <silent> [Tag]h :tabprevious<CR>


"###########################################################
"# カーソル移動関連の設定                                      #
"###########################################################
" Backspaceキーの影響範囲に制限を設けない
set backspace=indent,eol,start
" 行頭行末の左右移動で行をまたぐ
set whichwrap=b,s,h,l,<,>,[,]
" 上下8行の視界を確保
set scrolloff=8
" 左右スクロール時の視界を確保
set sidescrolloff=16
" 左右スクロールは一文字づつ行う
set sidescroll=1
" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore

" Insertモードのときカーソルの形状を変更
if has('nvim')
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1
elseif empty($TMUX)
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
"  let &t_SR = "\<Esc>]50;CursorShape=2\x7"
else
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
"  let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
endif


"###########################################################
"# ファイル処理関連の設定                                      #
"###########################################################
" 保存されていないファイルがあるときは終了前に保存確認
set confirm
" 保存されていないファイルがあるときでも別のファイルを開くことが出来る
set hidden
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" ファイル保存時にバックアップファイルを作らない
set nobackup
" ファイル編集中にスワップファイルを作らない
set noswapfile


"###########################################################
"# 検索の設定                                                #
"###########################################################
" 検索文字列をハイライトする
set hlsearch
" f連打でハイライト解除
nmap <silent>ff :nohlsearch<CR><Esc>
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" vimgrep時にquickfix-windowで一覧表示
autocmd QuickFixCmdPost *grep* cwindow
" 無視するディレクトリ
let Grep_Skip_Dirs = '.svn .git'
" バイナルファイルを無視
let Grep_Default_Options = '-I'
" バックアップファイルを無視
let Grep_Skip_Files = '*.bak *~'


"###########################################################
"# 置換の設定                                                #
"###########################################################
" 置換の時 g オプションをデフォルトで有効にする
set gdefault


"###########################################################
"# タブ/インデントの設定                                       #
"###########################################################
" Tab文字を半角スペースにする
set expandtab
" 行頭以外のTab文字の表示幅（スペースいくつ分）
set tabstop=4
" 自動インデントでずれる幅
set shiftwidth=4
 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set softtabstop=4
" 改行時に前の行のインデントを継続する
set autoindent
" 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set smartindent
" 文脈によって解釈が異なる全角文字の幅を、2に固定する
set ambiwidth=double


"###########################################################
"# コマンドラインの設定                                        #
"###########################################################
" コマンドラインモードでの補完を有効にする
set wildmenu
" コマンドラインモードでの補完方法を設定する
set wildmode=list:longest,full
" コマンドラインの履歴を10000件保存する
set history=10000


"###########################################################
"# キーマップの設定                                           #
"###########################################################
" マップリーダー変更
let mapleader = "\<Space>"

" インサートモードから抜ける
inoremap jj <ESC>

inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-b> <Left>
inoremap <C-f> <Right>

inoremap <C-e> <Esc>$a
inoremap <C-a> <Esc>^a

noremap <C-e> <Esc>$
noremap <C-a> <Esc>^

" <Space>v で1行選択(\n含まず)
noremap <Leader>v 0v$h


"###########################################################
"# その他の設定                                              #
"###########################################################
" viとの互換性解除(矢印キーでABCDが出る問題の改善)
set nocompatible

" ファイル読み込み時の文字コードの設定
set encoding=utf-8
" 文字コードをUFT-8に設定
set fenc=utf-8
" 保存時の文字コード
set fileencoding=utf-8
" 読み込み時の文字コードの自動判別. 左側が優先される
set fileencodings=utf-8,euc-jp,cp932
 " 改行コードの自動判別. 左側が優先される
set fileformats=unix,dos,mac
 " □や○文字が崩れる問題を解決
set ambiwidth=double

" "0"で始まる数値を、8進数として扱わないようにする
set nrformats-=octal

" マウスの入力を受け付ける
set mouse=a
" Windows でもパスの区切り文字を / にする
set shellslash

" ヤンクでクリップボードにコピー
set clipboard=unnamed,unnamedplus

"ビープ音すべてを無効にする
set visualbell t_vb=
"エラーメッセージの表示時にビープを鳴らさない
set noerrorbells

" ファイル保存時に余分な半角スペースを削除する
function! s:remove_dust()
    let cursor = getpos(".")
    %s/\s\+$//ge
    call setpos(".", cursor)
    unlet cursor
endfunction
autocmd BufWritePre * call <SID>remove_dust()

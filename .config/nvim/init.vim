"###########################################################
"# dein.vimの設定                                           #
"###########################################################
if &compatible
  set nocompatible
endif

" deinパス設定
if exists("$SSHHOME")
  let s:dein_dir = fnamemodify($SSHHOME . '/.dein/', ':p')
else
  let s:dein_dir = fnamemodify('~/.dein/', ':p')
endif
let s:dein_repo_dir = s:dein_dir . 'repos/github.com/Shougo/dein.vim'

" gitがなければインストール
if executable('yum') && !executable('git')
    execute '!sudo yum -y --quiet install git'
elseif executable('apt-get') && !executable('git')
    execute '!sudo apt-get -yq install git'
endif

" dein.vim本体の存在チェックとインストール
if !isdirectory(s:dein_repo_dir) && executable('git')
    execute '!git clone https://github.com/Shougo/dein.vim' shellescape(s:dein_repo_dir)
endif

" dein.vim本体をランタイムパスに追加
if &runtimepath !~# '/dein.vim'
    execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)

    " プラグインリストを収めた TOML ファイル
    let s:toml      = expand(s:dein_dir . 'dein.toml')
    let s:lazy_toml = expand(s:dein_dir . 'dein_lazy.toml')

    " TOML を読み込み、キャッシュしておく
    call dein#load_toml(s:toml,      {'lazy': 0})
    call dein#load_toml(s:lazy_toml, {'lazy': 1})

    call dein#end()
    call dein#save_state()
endif

filetype plugin indent on
syntax enable

" プラグインのインストール
if dein#check_install()
  call dein#install()
endif


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


"######################################################################################
"# プラグインの設定                                                                      #
"######################################################################################
"###########################################################
"# vim-monokaiの設定                                        #
"###########################################################
colorscheme monokai
set t_Co=256


"###########################################################
"# vim-quickhlの設定                                        #
"###########################################################
nmap <Leader>m <Plug>(quickhl-manual-this)
xmap <Leader>m <Plug>(quickhl-manual-this)
nmap <Leader><Leader> <Plug>(quickhl-manual-reset)
xmap <Leader><Leader> <Plug>(quickhl-manual-reset)


"###########################################################
"# accelerated-jkの設定                                     #
"###########################################################
" j/kによる移動を速くする
nmap j <Plug>(accelerated_jk_gj)
nmap k <Plug>(accelerated_jk_gk)


"###########################################################
"# vim-gitgutterの設定                                      #
"###########################################################
set updatetime=500


"###########################################################
"# vim-indent-guidesの設定                                  #
"###########################################################
" スタート時に有効にする
let g:indent_guides_enable_on_vim_startup = 1
" 最初の行を無効
let g:indent_guides_start_level = 2
" インデント幅
let g:indent_guides_guide_size = 1
" インデント除外ファイルタイプ
let g:indent_guides_exclude_filetypes = ['help', 'nerdtree', 'tagbar', 'unite']
" デフォルトカラーOFF
let g:indent_guides_auto_colors = 0
" 偶数カラー
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=235
" 奇数カラー
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=236


"###########################################################
"# lightline.vimの設定                                      #
"###########################################################
set guifont=Ricty\ 10

let g:lightline = {
        \ 'colorscheme': 'wombat',
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
        \ },
        \ 'component': {
        \   'lineinfo': '%3l[%L]:%-2v'
        \ },
        \ 'component_function': {
        \   'modified': 'LightlineModified',
        \   'readonly': 'LightlineReadonly',
        \   'fugitive': 'LightlineFugitive',
        \   'filename': 'LightlineFilename',
        \   'fileformat': 'LightlineFileformat',
        \   'filetype': 'LightlineFiletype',
        \   'fileencoding': 'LightlineFileencoding',
        \   'mode': 'LightlineMode'
        \ },
        \ 'separator': { 'left': "\u2b80", 'right': "\u2b82" },
        \ 'subseparator': { 'left': "\u2b81", 'right': "\u2b83" }
\ }


function! LightlineModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightlineReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
endfunction

function! LightlineFilename()
  return ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != LightlineModified() ? ' ' . LightlineModified() : '')
endfunction

function! LightlineFugitive()
  if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
    return fugitive#head()
  else
    return ''
  endif
endfunction

function! LightlineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineFileencoding()
  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction

function! LightlineMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction


"###########################################################
"# nerdtreeの設定                                           #
"###########################################################
" 隠しファイルをデフォルトで表示させる
let NERDTreeShowHidden = 1
" ctrl+k, ctrl+bでツリー表示/非表示
nnoremap <C-k><C-b> :NERDTreeToggle<CR>


"###########################################################
"# ctrlp.vimの設定                                          #
"###########################################################
" キャッシュディレクトリ
let g:ctrlp_cache_dir = '~/.cache/ctrlp'
" 遅延再描画
let g:ctrlp_lazy_update = 1
" CtrlPのウィンドウ最大高さ
let g:ctrlp_max_height = 20
" .(ドット)から始まるファイルも検索対象にする
let g:ctrlp_show_hidden = 1
" ファイル検索のみ使用
let g:ctrlp_types = ['fil']
" 無視するディレクトリ
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

" grepをagに置き換える
if executable('ag')
  let g:ctrlp_use_caching = 0
  let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup -g ""'
endif


"###########################################################
"# unite.vimの設定                                          #
"###########################################################
" 大文字小文字を区別しない
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1

" ESCキーを2回押すと終了する
au FileType unite nnoremap <silent> <buffer> <Leader><Leader> :q<CR>
au FileType unite inoremap <silent> <buffer> <Leader><Leader> <ESC>:q<CR>

" uniteのキーマップ
nnoremap    [unite]   <Nop>
nmap    <Leader>u [unite]

" uniteコマンド
nnoremap [unite]u  :<C-u>Unite -no-split<Space>
" ファイル一覧表示
nnoremap <silent> [unite]f :<C-u>Unite<Space>file<CR>
" カレントディレクトリを表示
nnoremap <silent> [unite]d :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" grep機能呼び出し
nnoremap <silent> [unite]g :<C-u>Unite<Space>grep<CR>
" バッファー表示
nnoremap <silent> [unite]b :<C-u>Unite<Space>buffer<CR>
" レジストリを表示
nnoremap <silent> [unite]r :<C-u>Unite<Space>register<CR>
" タブを表示
nnoremap <silent> [unite]t :<C-u>Unite<Space>tab<CR>
" 新規ファイル作成
nnoremap <silent> [unite]n :<C-u>Unite<Space>file/new<CR>
" ヤンクの履歴
nnoremap <silent> [unite]y :<C-u>Unite history/yank<CR>

" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif


"###########################################################
"# neocompleteの設定                                        #
"###########################################################
" Vim起動時にneocompleteを有効にする
let g:neocomplete#enable_at_startup = 1
" smartcase有効化. 大文字が入力されるまで大文字小文字の区別を無視する
let g:neocomplete#enable_smart_case = 1
" 3文字以上の単語に対して補完を有効にする
let g:neocomplete#sources#syntax#min_keyword_length = 3
" 区切り文字まで補完する
let g:neocomplete#enable_auto_delimiter = 1

" shift-tabで逆順選択
inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"


"###########################################################
"# neocomplete_phpの設定                                    #
"###########################################################
let g:neocomplete_php_locale = 'ja'


"###########################################################
"# deocompleteの設定                                        #
"###########################################################
" スタート時に有効にする
let g:deoplete#enable_at_startup = 1


"###########################################################
"# neosnippetの設定                                         #
"###########################################################
imap <C-l>     <Plug>(neosnippet_expand_or_jump)
smap <C-l>     <Plug>(neosnippet_expand_or_jump)

" タブキーで補完候補の選択. スニペット内のジャンプもタブキーでジャンプ
imap <expr><TAB> pumvisible() ? "\<C-n>" : neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
if has('conceal')
    set conceallevel=2 concealcursor=niv
endif


"###########################################################
"# syntasticの設定                                          #
"###########################################################
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_enable_signs = 1
let g:syntastic_echo_current_error = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_highlighting = 0

let g:syntastic_mode_map = {
     \ 'mode': 'active',
     \ 'active_filetypes': ['php'],
     \ 'passive_filetypes': []
     \}
let g:syntastic_php_checkers = ['php', 'phpcs']
let g:syntastic_php_phpcs_args='--standard=psr2'

let g:syntastic_quiet_messages = {
    \ "level":"warnings",
    \ 'regex': 'is not in camel caps format\|Each class must be in a namespace of at least one level'
\ }


"###########################################################
"# vim-easymotionの設定                                     #
"###########################################################
" ホームポジションに近いキーを使う
let g:EasyMotion_keys='hjklasdfgyuiopqwertnmzxcvb'
" 1 ストローク選択を優先する
let g:EasyMotion_grouping=1
" デフォルトマッピングをオフ
let g:EasyMotion_do_mapping = 0

map <Leader>l <Plug>(easymotion-bd-jk)
nmap <Leader>l <Plug>(easymotion-overwin-line)

map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)


"###########################################################
"# winresizerの設定                                         #
"###########################################################
let g:winresizer_start_key = '<C-t>'


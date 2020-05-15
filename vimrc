set shell=/bin/bash " use bash instead of fish to make PluginInstall works

" ================ Path ====================
set path+=~/KapIT/iob/server/client-html/src/main/resources/client-html-src/src/app
set suffixesadd+=.js

" ================ General Config ====================
set number                      "Line numbers are good
set relativenumber
set backspace=indent,eol,start  "Allow backspace in insert mode
set showcmd                     "Show incomplete cmds down the bottom
set cursorline                  "Highlight current line
set autoread                    "Reload files changed outside vim
set history=1000                "Store lots of cmd line history
set gdefault                    "Always substitue globally
set wildmenu                    "Display menu on autocomplete
au FocusGained,BufEnter * :checktime
autocmd FileType gitcommit set textwidth=80
autocmd FileType gitcommit set colorcolumn=81


" augroup test
"   autocmd!
"   autocmd BufWrite * if test#exists() |
"     \   TestFile |
"     \ endif
" augroup END

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" " http://items.sjbach.com/319/configuring-vim-right
set hidden

" Change leader to a comma because the backslash is too far away
" That means all \x commands turn into ,x
" The mapleader has to be set before vundle starts loading all
" the plugins.
let mapleader=","

" ================ Turn Off Swap Files ==============
set noswapfile
set nobackup
set nowb

" ================ Navigation    ====================
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
"C-A doesn't work to increment number
noremap <C-I> <C-A>

nnoremap <C-W><C-V> :AV<CR>

"Double tap i while in insert to go to the end of the line.
inoremap ii <Esc>$a
inoremap i; <Esc>$a;

inoremap <leader>o <Esc>O

set splitright
nnoremap ` '

" ================ Undo/Redo ========================
set undofile
set undodir=~/.vim/undodir
" ================ Search    ========================
set hlsearch
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
set ignorecase
set smartcase
set incsearch

" ================ Scrolling ========================
set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1


call plug#begin('~/.vim/plugged')

Plug 'jiangmiao/auto-pairs'
Plug 'gmarik/Vundle.vim'
Plug 'rking/ag.vim'
Plug 'sjl/gundo.vim'
Plug 'w0rp/ale'
Plug 'tpope/vim-commentary'
Plug 'terryma/vim-expand-region'
Plug 'tpope/vim-fugitive'
Plug 'shumphrey/fugitive-gitlab.vim'
Plug 'groenewege/vim-less'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'pangloss/vim-javascript'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'tpope/vim-unimpaired'
Plug 'wincent/terminus'
Plug 'mattn/emmet-vim'
Plug 'majutsushi/tagbar'
Plug 'aklt/vim-substitute'
Plug 'wakatime/vim-wakatime'
Plug 'Shougo/vimproc'
Plug 'itchyny/lightline.vim'
Plug 'elmcast/elm-vim'
Plug 'othree/html5-syntax.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'rhysd/committia.vim'
Plug 'AndrewRadev/linediff.vim'
Plug 'jasonshell/vim-svg-indent'
Plug 'heavenshell/vim-jsdoc'
Plug 'elixir-lang/vim-elixir'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Plug 'janko-m/vim-test'
Plug 'benmills/vimux'
Plug 'davinche/godown-vim'
Plug 'lifepillar/vim-cheat40'
Plug 'gu-fan/riv.vim'
Plug 'tpope/vim-db'
Plug 'tpope/vim-scriptease'
Plug 'henrik/vim-reveal-in-finder'
Plug 'AaronLasseigne/yank-code'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'wellle/targets.vim'
" Plug 'janko-m/vim-test'
" Plug 'tpope/vim-projectionist'
call plug#end()  " required


" ================ Indentation ======================
set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set modelines=1
set clipboard=unnamed

syntax enable "turn on syntax highlighting
" let g:solarized_termtrans = 1
" colorscheme solarized
colorscheme Tomorrow-Night
:set background=dark

" ============== Custom bindings ==================
" remove whitespace on save
autocmd BufWritePre * :%s/\s\+$//e
" create file as soon as edit it
autocmd BufNewFile * :write

autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

autocmd BufNewFile,BufReadPost *.md set filetype=markdown
au BufRead,BufNewFile *.rst setlocal textwidth=80
au BufRead,BufNewFile *.po setlocal textwidth=80

" Open vimrc and autoreload config
nnoremap <leader>v :e ~/.vimrc<CR>
augroup reload_vimrc " {
  autocmd!
  autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END " }

" Yank text to the OS X clipboard
noremap <leader>y "*y
noremap <leader>yy "*Y

" Copy file path on clipboard
noremap <silent> <F4> :let @+=expand("%")<CR>

" Preserve indentation while pasting text from the OS X clipboard
noremap <leader>p :set paste<CR>:put    *<CR>:set nopaste<CR>

" strip all trailing whitespace in the current file
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" reselect pasted text
nnoremap <leader>V V`]

nnoremap <leader>l :call ToggleNumber()<CR>

" format json
nnoremap ,f :%!python -m json.tool<CR>
" jj to switch to normal mode
inoremap jj <Esc>

noremap <silent> <C-S>          :wa<CR>
vnoremap <silent> <C-S>         <C-C>:wa<CR>
inoremap <silent> <C-S>         <C-O>:wa<CR>

vnoremap <Down> :m '>+1<CR>gv=gv
vnoremap <Up> :m '<-2<CR>gv=gv

" selection will be substituted with your current register. Allow to replace
" a selection without yanking it
vnoremap r "_dP"
" ============= Plugin Configuration ============
" ag config
let g:ag_prg='ag -S --nocolor --nogroup --column --ignore node_modules --ignore target --ignore bower_components --ignore logs'
nnoremap <leader>a :Ag --js

nnoremap <buffer> <silent> S :Cycle<CR>

nnoremap <leader>; A,<Esc>o

" remap [ and ] because I use azerty keyboard
nmap ù [
nmap ` ]
omap ù [
omap ` ]
xmap ù [
xmap ` ]

" html indentation
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"
let g:html_indent_inctags = "html,body,head"

nmap <F8> :TagbarToggle<CR>

let g:substitute_PromptMap = "'&"
let g:substitute_NoPromptMap = '&&'
let g:substitute_GlobalMap = "&'"
let g:fugitive_gitlab_domains= ['http://git.kapit.biz']
let g:elm_format_autosave = 1
let g:elm_setup_keybindings = 1
let g:elm_make_show_warnings = 0

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:elm_syntastic_show_warnings = 0

let g:ycm_semantic_triggers = {
     \ 'elm' : ['.'],
     \}

let g:used_javascript_libs = 'angularjs,jasmine' "syntax highlight

" lightline config
set laststatus=2 "otherwise lightline appears only on :vsp
let g:lightline = {
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ],
    \   'right': [['syntastic', 'lineinfo'], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ]]
    \ },
    \ 'component': {
    \   'readonly': '%{&filetype=="help"?"":&readonly?"⭤":""}',
    \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
    \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
    \ },
    \ 'component_visible_condition': {
    \   'readonly': '(&filetype!="help"&& &readonly)',
    \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
    \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
    \ },
    \ }

let g:tmuxline_powerline_separators = 0
let g:tmuxline_preset = {
      \'a'    : '#I #W',
      \'win'  : '#I #W',
      \'cwin' : '#I #W',
      \'x'    : '%a',
      \'y'    : '%R'}

" neocomplete
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
" <TAB>: completion
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"
" ================= Custom Functions ====================

" toggle between number and relativenumber
function! ToggleNumber()
    if(&relativenumber == 1)
        set norelativenumber
        set number
    else
        set relativenumber
    endif
endfunc
" vim:foldmethod=marker:foldlevel=0

" https://gist.github.com/wellle/9289224
nnoremap <silent> <Leader>p :set opfunc=Append<CR>g@ "append text inside text object
nnoremap <silent> <Leader>i :set opfunc=Insert<CR>g@ "insert text inside text object

function! Append(type, ...)
    call feedkeys("`]a", 'n')
endfunction

function! Insert(type, ...)
    call feedkeys("`[i", 'n')
endfunction

let g:jsdoc_allow_input_prompt = 1
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

" Put the searched word in the middle of the screen.
nnoremap <silent>n nzz
nnoremap <silent>N Nzz
nnoremap <silent>* *zz

let g:fzf_action = {
      \ 'ctrl-s': 'split',
      \ 'ctrl-v': 'vsplit'
      \ }
nnoremap <c-p> :GFiles<cr>
nnoremap <S-b> :Buffers<cr>
nnoremap <S-h> :History<cr>
nnoremap <S-t> :Tags<cr>
nmap <Leader>l :BLines<CR>
nmap <Leader>L :Lines<CR>
nmap <Leader>: :History:<CR>
nmap <Leader>/ :History/<CR>
nmap <Leader>M :Maps<CR>

imap <C-f> <plug>(fzf-complete-line)

for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '%', '-', '#' ]
    execute 'xnoremap i' . char . ' :<C-u>normal! T' . char . 'vt' . char . '<CR>'
    execute 'onoremap i' . char . ' :normal vi' . char . '<CR>'
    execute 'xnoremap a' . char . ' :<C-u>normal! F' . char . 'vf' . char . '<CR>'
    execute 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor

" Next and Last test-objects
" din( delete inside the next parenthesis
onoremap an :<c-u>call <SID>NextTextObject('a', 'f')<cr>
xnoremap an :<c-u>call <SID>NextTextObject('a', 'f')<cr>
onoremap in :<c-u>call <SID>NextTextObject('i', 'f')<cr>
xnoremap in :<c-u>call <SID>NextTextObject('i', 'f')<cr>

onoremap al :<c-u>call <SID>NextTextObject('a', 'F')<cr>
xnoremap al :<c-u>call <SID>NextTextObject('a', 'F')<cr>
onoremap il :<c-u>call <SID>NextTextObject('i', 'F')<cr>
xnoremap il :<c-u>call <SID>NextTextObject('i', 'F')<cr>

function! s:NextTextObject(motion, dir)
  let c = nr2char(getchar())

  if c ==# "b"
      let c = "("
  elseif c ==# "B"
      let c = "{"
  elseif c ==# "r"
      let c = "["
  endif

  exe "normal! ".a:dir.c."v".a:motion.c
endfunction

nmap <silent> <leader>T :TestNearest<CR>
nmap <silent> <leader>t :TestFile<CR>
let test#strategy = "vimux"

let g:cheat40_use_default = 0

" ale config
let g:ale_lint_on_text_changed='never'
nmap <silent> <C-n> <Plug>(ale_next_wrap)
let g:ale_set_loclist = 1
let g:ale_open_list = 1
let g:ale_linters = {'javascript': ['eslint'], 'html': [], 'less': ['stylelint']}
let g:ale_list_window_size = 5

nmap <silent> <leader>, :only<CR>

nnoremap <silent> <Leader>c :cd ~/KapIT/iob/<CR>

nmap <silent> <leader>w A<Space><Backspace><Esc>:write<CR>

let g:deoplete#enable_at_startup = 1

nmap <silent> <Leader>t :TestFile<CR>

let test#javascript#mocha#file_pattern = '**\**.test.js'
let g:test#preserve_screen = 0

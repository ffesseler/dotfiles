set shell=/bin/bash " use bash instead of fish to make PluginInstall works

" Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
filetype off

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

set splitright
nnoremap ` '

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

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin() "let Vundle manage Vundle, required

Plugin 'jiangmiao/auto-pairs'
Plugin 'gmarik/Vundle.vim'
Plugin 'https://github.com/kien/ctrlp.vim'
Plugin 'rking/ag.vim'
Plugin 'sjl/gundo.vim'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-commentary'
Plugin 'terryma/vim-expand-region'
Plugin 'tpope/vim-fugitive'
Plugin 'shumphrey/fugitive-gitlab.vim'
Plugin 'groenewege/vim-less'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-vinegar'
Plugin 'pangloss/vim-javascript'
Plugin 'othree/javascript-libraries-syntax.vim'
Plugin 'tpope/vim-unimpaired'
Plugin 'wincent/terminus'
Plugin 'mattn/emmet-vim'
Plugin 'ternjs/tern_for_vim'
Plugin 'majutsushi/tagbar'
Plugin 'aklt/vim-substitute'
Bundle 'wakatime/vim-wakatime'
Plugin 'Shougo/vimproc'
Plugin 'itchyny/lightline.vim'
Plugin 'elmcast/elm-vim'
Plugin 'Shougo/neocomplete.vim'
Plugin 'Shougo/neosnippet'
Plugin 'Shougo/neosnippet-snippets'
Plugin 'othree/html5-syntax.vim'
Plugin 'edkolev/tmuxline.vim'
Plugin 'rhysd/committia.vim'
Plugin 'AndrewRadev/linediff.vim'
call vundle#end()  " required
filetype plugin indent on  " required

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

autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Open vimrc and autoreload config
nnoremap <leader>v :e ~/.vimrc<CR>
augroup reload_vimrc " {
  autocmd!
  autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END " }

" Yank text to the OS X clipboard
noremap <leader>y "*y
noremap <leader>yy "*Y

" Preserve indentation while pasting text from the OS X clipboard
noremap <leader>p :set paste<CR>:put    *<CR>:set nopaste<CR>

" strip all trailing whitespace in the current file
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" reselect pasted text
nnoremap <leader>V V`]

nnoremap <leader>l :call ToggleNumber()<CR>

" format json
nmap =f :%!python -m json.tool<CR>
" jj to switch to normal mode
inoremap jj <Esc>

noremap <silent> <C-S>          :wa<CR>
vnoremap <silent> <C-S>         <C-C>:wa<CR>
inoremap <silent> <C-S>         <C-O>:wa<CR>

vnoremap <Down> :m '>+1<CR>gv=gv
vnoremap <Up> :m '<-2<CR>gv=gv

" selection will be substituted with your current register. Allow to replace
" a selection without yanking it
vmap r "_dP"
" ============= Plugin Configuration ============

" exclude directories from showing in ctrl p
let g:ctrlp_custom_ignore = {
    \ 'dir': '\.git$\|bower_components$\|node_modules$\|target$\|logs$\|log$'}
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_working_path_mode = 0

" ag config
let g:ag_prg='ag -S --nocolor --nogroup --column --ignore node_modules --ignore target --ignore bower_components --ignore logs'
nnoremap <leader>a :Ag --js

let g:syntastic_javascript_checkers=['eslint']
" let g:syntastic_typescript_checkers=['tslint', 'eslint']
" let g:syntastic_typescript_tsc_fname = '' "http://stackoverflow.com/questions/34102184/use-tsconfig-json-for-tsc-with-syntastic-in-vim
let g:syntastic_java_checkers=[]
let g:syntastic_html_checkers = ['tidy']
let g:syntastic_html_tidy_exec = 'tidy'

nnoremap <buffer> <silent> S :Cycle<CR>

nnoremap <leader>; A,<Esc>o

" remap [ and ] because I use azerty keyboard
nmap ù [
nmap ` ]
omap ù [
omap ` ]
xmap ù [
xmap ` ]

" UltiSnip config
let g:UltiSnipsListSnippets='<c-i>'
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

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

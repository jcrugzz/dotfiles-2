" Required:
filetype plugin indent on

" Basic Setup
"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set ttyfast
set nocompatible

"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overridden by autocmd rules
set tabstop=2
set softtabstop=0
set shiftwidth=2
set expandtab

"" Map leader to ,
let mapleader=','

"" Enable hidden buffers
set hidden

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase
" turn off highlights
nnoremap <leader><space> :nohlsearch<CR>
" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

" disable annoying bells and gui options
set vb
set t_vb=
set guioptions-=m
set guioptions-=T

"" Visual
syntax on
set number 
set showcmd
set ruler
let &colorcolumn=join(range(81,999),",")
let &colorcolumn="80,".join(range(400,999),",")

"" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

" Status line settings
set laststatus=2
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\

" move vertically by lines on terminal
nnoremap j gj
nnoremap k gk

" jk is escape
inoremap jk <esc>

" buffer switcher
:nnoremap <leader>b :buffers<CR>:buffer<Space>

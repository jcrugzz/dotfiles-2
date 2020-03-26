"*****************************************************************************
"" Vim-Plug core
"*****************************************************************************
let vimplug_exists=expand('~/.vim/autoload/plug.vim')

let g:vim_bootstrap_langs = "go,html,javascript,ruby,rust,typescript"
let g:vim_bootstrap_editor = "vim"				" nvim or vim

if !filereadable(vimplug_exists)
  if !executable("curl")
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent exec "!\curl -fLo " . vimplug_exists . " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif

" Required:
call plug#begin(expand('~/.vim/plugged'))

Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/grep.vim'
Plug 'vim-scripts/CSApprox'
Plug 'Raimondi/delimitMate'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-rhubarb'
Plug 'sjl/gundo.vim'
Plug 'dense-analysis/ale'
Plug 'preservim/nerdtree'

" Make autocomplete happen 
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'

if isdirectory('/usr/local/opt/fzf')
  Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
else
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
  Plug 'junegunn/fzf.vim'
endif

let g:make = 'gmake'
if exists('make')
        let g:make = 'make'
endif
Plug 'Shougo/vimproc.vim', {'do': g:make}

" Theme
Plug 'tomasr/molokai'

" Language support

" go
Plug 'fatih/vim-go', {'do': ':GoInstallBinaries'}

" javascript
Plug 'jelera/vim-javascript-syntax'

" ruby
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rake'
Plug 'tpope/vim-projectionist'
Plug 'thoughtbot/vim-rspec'
Plug 'ecomba/vim-ruby-refactoring'

" rust
Plug 'racer-rust/vim-racer'
Plug 'rust-lang/rust.vim'

" typescript
Plug 'leafgarland/typescript-vim'
Plug 'HerringtonDarkholme/yats.vim'

call plug#end()

" Required:
filetype plugin indent on

" Basic Setup
"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set ttyfast

"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overridden by autocmd rules
set tabstop=2
set softtabstop=0
set shiftwidth=2
set expandtab

"" Map leader to ,
let mapleader=','

"Gundo
nnoremap <leader>u  :GundoToggle<CR>

" ALE
let g:ale_linters = {'ruby': ['rubocop']}
let g:ale_sign_error = '!' 
let g:ale_sign_warning = '?'
let g:ale_linters_explicit = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_disable_lsp = 1
let g:ale_sign_column_always = 1

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
if exists("*fugitive#statusline")
  set statusline+=%{fugitive#statusline()}
endif

" vim-airline
let g:airline_theme = 'powerlineish'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1

" ctrlp
let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_switch_buffer = 0
let g:ctrlp_working_path_mode = 0
" Use ripgrep if available
if executable('rg')
  set grepprg=rg\ --color=never
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  let g:ctrlp_use_caching = 1
else
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
endif

"
" move vertically by lines on terminal
nnoremap j gj
nnoremap k gk

" airline settings
let g:airline_powerline_fonts = 1
let g:airline_theme='murmur'

" jk is escape
inoremap jk <esc>

" nerdtree
map <leader>n :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" language client servr settings
let tsserver = system('echo -n $(npm config get prefix)/bin/javascript-typescript-stdio')
let ra_lsp_server = system('echo -n $HOME/.cargo/bin/ra_lsp_server')
let solargraph = system('echo -n $(which solargraph)')
let g:LanguageClient_serverCommands = {
    \ 'rust': [ra_lsp_server],
    \ 'typescript': [tsserver],
    \ 'javascript': [tsserver],
    \ 'javascript.jsx': [tsserver],
    \ 'ruby': [solargraph, 'stdio'],
    \ }
let g:deoplete#enable_at_startup = 1
let g:neosnippet#enable_complete_done = 1
let g:deoplete#auto_complete_delay = 500

function LC_maps()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    nnoremap <F5> :call LanguageClient_contextMenu()<CR>
    nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<cr>
    nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
    nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
  endif
endfunction

autocmd FileType * call LC_maps()

silent! colorscheme molokai

autocmd FileType ruby,typescript,javascript autocmd BufWritePre <buffer> %s/\s\+$//e

" buffer switcher
:nnoremap <leader>b :buffers<CR>:buffer<Space>

let os = substitute(system('uname'), "\n", "", "")
if has("gui_running")
  if os == "Darwin"
    set guifont=Hack:h12
  else
    set guifont=Hack\ 12
  endif
endif

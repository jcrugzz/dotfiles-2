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
Plug 'dense-analysis/ale'
Plug 'preservim/nerdtree'
Plug 'vimwiki/vimwiki'
Plug 'mbbill/undotree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

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
Plug 'cocopon/iceberg.vim'

" Language support

" go, yeah i get it, our dev instances are fucking hold stop nagging
Plug 'fatih/vim-go', {'do': ':GoInstallBinaries'}
let g:go_version_warning = 0

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

" hcl
Plug 'jvirtanen/vim-hcl'

call plug#end()

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

" Undo tree
nnoremap <leader>u  :UndotreeToggle<CR>

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
"let tsserver = system('echo -n $(npm config get prefix)/bin/javascript-typescript-langserver')
" let ra_lsp_server = system('echo -n $HOME/.cargo/bin/ra_lsp_server')
" let solargraph = system('echo -n $(which solargraph)')
" let g:LanguageClient_serverCommands = {
"     \ 'rust': [ra_lsp_server],
"     \ 'typescript': ['tcp://127.0.0.1:2089'],
"     \ 'javascript': ['tcp://127.0.0.1:2089'],
"     \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
"     \ 'ruby': [solargraph, 'stdio'],
"     \ }
" let g:deoplete#enable_at_startup = 1
" let g:neosnippet#enable_complete_done = 1
" let g:deoplete#auto_complete_delay = 300
" 
" function LC_maps()
"   if has_key(g:LanguageClient_serverCommands, &filetype)
"     nnoremap <F5> :call LanguageClient_contextMenu()<CR>
"     nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<cr>
"     nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
"     nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
"   endif
" endfunction
" 
" autocmd FileType * call LC_maps()

" coc.vim
set hidden
set nobackup
set nowritebackup
set updatetime=300
set shortmess+=c
set signcolumn=yes
let g:coc_global_extensions = [
  \ "coc-solargraph", 
  \ "coc-json",
  \ "coc-tsserver",
  \ ]

" use tab for trigger completion with characters
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

" use <c-space> to trigger competion.
inoremap <silent><expr> <c-space> coc#refesh()

" use <cr> to confirm completion
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <F2> <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument/selectionRange' support from the language server.
" coc-tsserver, coc-python are the examples of servers that support it.
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>


autocmd FileType ruby,typescript,javascript autocmd BufWritePre <buffer> %s/\s\+$//e

" buffer switcher
:nnoremap <leader>b :buffers<CR>:buffer<Space>

" run a test
:nnoremap <leader>t :exe "!bin/tt %:" . line(".")<CR>

" use fzf instead of ctrl-p
nnoremap <C-p> :Files<CR>
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Find call fzf#vim#files('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)
endif

" vimwiki
let g:vimwiki_list = [{'path': '~/src/vimwiki', 'syntax': 'markdown', 'ext': '.md'}]

let os = substitute(system('uname'), "\n", "", "")
if has("gui_running")
  if os == "Darwin"
    set guifont=Hack:h12
  else
    set guifont=Hack\ 12
  endif
endif

if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
  set termguicolors
end

silent! colorscheme iceberg

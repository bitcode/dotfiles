" ---------- Vundle & Plugins --------

set nocompatible              " be iMproved, required
filetype on                  " required                                        
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'neoclide/coc.nvim'
Plugin 'rust-lang/rust.vim'
Plugin 'racer-rust/vim-racer'
Plugin 'bash-support.vim'
Plugin 'VundleVim/Vundle.vim'
Plugin 'leafgarland/typescript-vim'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'maxmellon/vim-jsx-pretty'
Plugin 'tpope/vim-fugitive'
Plugin 'fatih/vim-go'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'scrooloose/nerdtree'
Plugin 'nginx.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'ryanoasis/vim-devicons'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'morhetz/gruvbox'
Plugin 'blackrush/vim-gocode'
Plugin 'sebdah/vim-delve'
Plugin 'shougo/vimshell.vim'
Plugin 'shougo/vimproc.vim'
Plugin 'xuyuanp/nerdtree-git-plugin'
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'luochen1990/rainbow'
Plugin 'roxma/vim-tmux-clipboard'
call vundle#end()            " required
filetype plugin indent on    " required

" ------------ Settings ------------------

language en_US.UTF8
syntax enable
syntax on
colorscheme gruvbox

set showmatch mat=2
set background=dark
set cursorline
set term=xterm-256color
set encoding=utf8
set backspace=indent,eol,start
set number
set wildmenu
set wildignore=*.o,*~,*/.git/*,*/target/*
set mouse=a
set clipboard=unnamedplus
set laststatus=2
set guifont=Iosevka\ Regular:h16

" -------- UI Settings ---------

let g:airline_powerline_fonts = 1
let g:airline_theme='powerlineish'
let g:Powerline_symbols = 'fancy'
let g:Powerline_symbols = 'unicode'
let g:onedark_terminal_italics = 1
let g:rainbow_active = 1

" ----- Go Plugin Settings highlighting --------

let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_variable_declarations = 1
let g:go_auto_sameids = 1
let g:go_fmt_command = "goimports"

"---- NERDtree plugin settings -------------

let NERDTreeShowHidden = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
let g:NERDTreeHighlightFolders = 1
let g:NERDTreeHighlightFoldersFullName = 1

" ----- Rust Plugin Settings ----------

let g:racer_experimental_completer = 1
let g:rustfmt_autosave = 1
let g:racer_insert_paren = 1

" ----- Typescript Plugin Settings -----

let g:typescript_compiler_binary = 'tsc'
let g:typescript_compiler_options = ''
autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow
"let g:typescript_ignore_browserwords

" ------ JSX Pretty Plugin Settings -----

let g:vim_jsx_pretty_highlight_close_tag = 1
let g:vim_jsx_pretty_colorful_config = 1

" vim-racer enables C-x-C-o to search for completion
" Example Mappings

augroup Racer
    autocmd!
    autocmd FileType rust nmap <buffer> gd         <Plug>(rust-def)
    autocmd FileType rust nmap <buffer> gs         <Plug>(rust-def-split)
    autocmd FileType rust nmap <buffer> gx         <Plug>(rust-def-vertical)
    autocmd FileType rust nmap <buffer> gt         <Plug>(rust-def-tab)
    autocmd FileType rust nmap <buffer> <leader>gd <Plug>(rust-doc)
augroup END

" ----- Rust Language Server settings --

if executable('rls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'rls',
        \ 'cmd': {server_info->['rustup', 'run', 'nightly', 'rls']},
        \ 'whitelist': ['rust'],
        \ })
endif

" ----- Remap yank & paste -------------

vnoremap <C-c> "+y
map <C-p> "+P

" --- Fix Lines on Scroll -----

if &term =~ '256color'
    " Disable Background Color Erase (BCE) so that color schemes
    " work properly when Vim is used inside tmux and GNU screen.
    set t_ut=
endif

" ------ NERDtree auto open w/ no args --------

function! StartUp()
    if 0 == argc()
        NERDTree
    end
endfunction
autocmd VimEnter * call StartUp()

" ----- Code of Completion Settings ---------



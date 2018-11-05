" Set vim colors to solarized
syntax enable
set background=dark
colorscheme solarized

" Set tab characters to 4 spaces
set tabstop=4
set shiftwidth=4

" Download and install Plug, plugin manager
" See https://github.com/junegunn/vim-plug for documentation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" Make sure you use single quotes
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
"Plug 'junegunn/vim-easy-align'

" Initialize plugin system
call plug#end()

" Title:        Dir
" Description:  A plugin to provide an alternative to netrw to browse
"               directories in vim-buffer-like style.
" Last Change:  19 January 2023
" Maintainer:   Paweł Placzyński <https://github.com/placek>

if exists("g:loaded_dir")
  finish
endif

let g:loaded_dir   = 1
let g:dir_filter   = '^[^\.].*'
let g:dir_filtered = 1

command! -nargs=1 -complete=dir -bang Dir edit<bang> <args>
command! -nargs=1 -complete=dir -bang Vir vsplit<bang> <args>
command! -nargs=1 -complete=dir -bang Sir split<bang> <args>
command! -nargs=0 DirWrite call dir#perform()

au BufEnter * silent call dir#render(expand("<amatch>"))

if exists("b:current_syntax")
  finish
endif

syntax match dirFile      /^.\+$/
syntax match dirDirectory /^.\+\/$/
syntax match dirHeader    /^\[.*\]$/

highlight link dirHeader    Comment
highlight link dirDirectory Directory
highlight link dirFile      File

let b:current_syntax = "dir"

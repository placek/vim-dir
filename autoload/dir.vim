function! dir#render(path)
  let l:path = a:path
  if isdirectory(l:path)
    let l:path = dir#unify_dir_path(l:path)
    let l:buf  = bufnr("%")
    call deletebufline(l:buf, 1, "$")
    call setbufline(l:buf, 1, dir#contents(l:path))
    call setbufvar(l:buf, "&filetype", "dir")
    call setbufvar(l:buf, "&buftype", "nofile")
  endif
endfunction

function! dir#contents(path)
  let l:name = "[".a:path."]"
  return [l:name] + map(dir#list(a:path), { _,v -> dir#render_item(v) })
endfunction

function! dir#list(path)
  if g:dir_filtered
    return readdirex(a:path, { n -> n.name =~ g:dir_filter })
  else
    return readdirex(a:path)
  end
endfunction

function! dir#buffer()
  if g:dir_filtered
    return filter(getline(2, "$"), { _, v -> v =~ g:dir_filter })
  else
    return getline(2, "$")
  endif
endfunction

function! dir#unify_dir_path(path)
  if a:path !~ "/$"
    return a:path."/"
  else
    return a:path
  endif
endfunction

function! dir#cd(path)
  execute "edit! ".a:path
endfunction

function! dir#edit(path)
  execute "edit! ".a:path
endfunction

function! dir#right()
  let l:type = synIDattr(synID(line("."), col("."), 0), "name")
  let l:path = getline(1)[1:-2] . getline(".")
  if l:type == "dirFile"
    call dir#edit(l:path)
  elseif l:type == "dirDirectory"
    call dir#cd(l:path)
  end
  return l:path
endfunction

function! dir#left()
  let l:cwd = getline(1)[1:-2]
  let l:path = substitute(l:cwd, "[^/]*/$", "", "")
  call dir#cd(l:path)
  return l:path
endfunction

function! dir#toggle_filter()
  if &ft == "dir"
    if g:dir_filtered == 0
      let g:dir_filtered = 1
    else
      let g:dir_filtered = 0
    endif
    call dir#render(getline(1)[1:-2])
  endif
endfunction

function! dir#perform()
  let l:changes = dir#changes()
  for action in keys(l:changes)
    for item in l:changes[action]
      if action == "remove"
        call dir#remove(item)
      elseif action == "create"
        call dir#create(item)
      endif
    endfor
  endfor
  call dir#render(getline(1)[1:-2])
endfunction

function! dir#render_item(item)
  if a:item.type == "dir"
    return a:item.name . "/"
  else
    return a:item.name
  endif
endfunction

function! dir#create(path)
  let l:choice = confirm(a:path." create?", "&Yes\n&No", 2)
  if l:choice == 1
    call writefile([], a:path)
    echom "created ".a:path
  endif
endfunction

function! dir#remove(path)
  let l:choice = confirm(a:path." remove?", "&Yes\n&No", 2)
  if l:choice == 1
    call delete(a:path, "rf")
    echom "removed ".a:path
  endif
endfunction

function! dir#changes()
  let l:cwd = getline(1)[1:-2]
  let l:x   = map(dir#list(l:cwd), { _,v -> l:cwd.dir#render_item(v) })
  let l:y   = map(dir#buffer(), { _,v -> l:cwd.v })
  return dir#diff(l:x, l:y)
endfunction

function! dir#diff(x, y)
  let l:left  = filter(copy(a:x), { _,v -> index(a:y, v) < 0 })
  let l:right = filter(copy(a:y), { _,v -> index(a:x, v) < 0 })
  return { "remove": l:left, "create": l:right }
endfunction

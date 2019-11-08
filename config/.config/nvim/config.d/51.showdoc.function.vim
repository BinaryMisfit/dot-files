" Show documentation
function! s:show_doc()
  if &filetype ==# 'vim'
    execute 'h ' . expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

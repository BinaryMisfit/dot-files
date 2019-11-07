" Enable the spell check for certain files
augroup enableSpell
  autocmd FileType markdown silent! setlocal spell spelllang=en_gb
augroup END

" Open the help on the left
augroup showHelpLeft
  autocmd FileType help silent! wincmd L
augroup END

" Change to the open file directory
augroup changeDir
  autocmd BufEnter * silent! lcd %:p:h
augroup END

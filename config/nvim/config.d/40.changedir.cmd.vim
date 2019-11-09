" Change to the open file directory
augroup changeDir
  autocmd BufEnter * silent! lcd %:p:h
augroup END

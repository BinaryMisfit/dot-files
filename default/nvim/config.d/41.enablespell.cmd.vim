" Enable the spell check for certain files
augroup enableSpell
  autocmd FileType markdown silent! setlocal spell spelllang=en_gb
augroup END

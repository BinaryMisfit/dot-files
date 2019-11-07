" Enable autoformat
augroup autoFormat
  autocmd!
  autocmd BufWrite * silent! :Autoformat
augroup END

" Change to the open file directory
augroup changeToFileDir
  autocmd!
  autocmd BufEnter * silent! lcd %:p:h
augroup END

" Enable the spell check for certain files
augroup enableSpell
  autocmd!
  autocmd FileType * silent! call SetSpellOn(&filetype)
augroup END

" Override specific theme settings
augroup fixTheme
  autocmd!
  "autocmd VimEnter * silent! call OverrideTheme()
augroup END

" Open the help on the left
augroup helpWindow
  autocmd!
  autocmd FileType help silent! wincmd L
augroup END

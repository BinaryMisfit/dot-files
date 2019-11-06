augroup autoFormat
  autocmd!
  "autocmd BufWrite * :Autoformat
augroup END

augroup changeToFileDir
  autocmd!
  autocmd BufEnter * silent! lcd %:p:h
augroup END

augroup enableSpell
  autocmd!
  autocmd FileType * silent! call ConfFileType(&filetype)
augroup END

augroup fixTheme
  autocmd!
  autocmd VimEnter * silent! call OverrideTheme()
augroup END

augroup helpWindow
  autocmd!
  autocmd FileType help silent! wincmd L
augroup END

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
  autocmd FileType * call ConfFileType(&filetype)
augroup END

augroup fixTheme
  autocmd!
  autocmd VimEnter * call OverrideTheme()
augroup END

augroup helpWindow
  autocmd!
  autocmd FileType help wincmd L
augroup END

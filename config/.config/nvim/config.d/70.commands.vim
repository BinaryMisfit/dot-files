augroup enableSpell
    autocmd!
    autocmd FileType markdown setlocal spell spelllang=en_GB
    autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_GB
augroup END

augroup changeToFileDir
    autocmd!
    autocmd BufEnter * silent! lcd %:p:h
augroup END

augroup removeTrailingSpaces
    autocmd!
    autocmd BufWritePre * %s/\s\+$//e
augroup END

augroup handleJsonC
    autocmd!
    autocmd FileType json syntax match Comment +\/\/.\+$+
augroup END

augroup gitLineWrap
    autocmd!
    autocmd Filetype gitcommit setlocal spell spelllang=en_GB textwidth=72
augroup END

augroup reloadVIMRC
    autocmd!
    autocmd BufWritePost stdpath('config') . '/config.d/*.vim' call ReloadConfig()
    autocmd BufWritePost $MYVIMRC call ReloadConfig()
    autocmd BufWritePost stdpath('config') . '/config.d/01.plugins.vim' call dein#update()
augroup END

augroup helpWindow
    autocmd!
    autocmd FileType help wincmd L
augroup END

augroup autoFormat
    autocmd!
    autocmd BufWrite * :Autoformat
augroup END

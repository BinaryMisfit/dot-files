autocmd! BufEnter * silent! lcd %:p:h
autocmd! BufWritePost $MYVIMRC call ReloadConfig()
autocmd! BufWritePre * %s/\s\+$//e
autocmd! FileType json syntax match Comment +\/\/.\+$+
autocmd! Filetype gitcommit setlocal spell textwidth=72
autocmd! CursorHold * silent call CocActionAsync('highlight')

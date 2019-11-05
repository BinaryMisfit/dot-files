if !exists('*ReloadConfig')
    fun! ReloadConfig()
        let save_cursor = getcurpos()
        source $MYVIMRC
        call setpos('.', save_cursor)
    endfun
endif

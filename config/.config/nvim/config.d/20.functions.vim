if !exists('*OverrideTheme')
  fun! OverrideTheme()
    highlight clear SignColumn
  endfun
endif

if !exists('*ConfFileType')
  fun! ConfFileType(filetype) abort
    if a:filetype == "markdown"
      setlocal spell spelllang=en_gb
    elseif a:filetype == "gitcommit"
      setlocal spell spelllang=en_gb
    endif
  endfun
endif

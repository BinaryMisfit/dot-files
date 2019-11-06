if !exists('*OverrideTheme')
  function! OverrideTheme()
    highlight clear SignColumn
  endfunction
endif

if !exists('*ConfFileType')
  function! ConfFileType(filetype) abort
    if a:filetype == "markdown"
      setlocal spell spelllang=en_gb
    elseif a:filetype == "gitcommit"
      setlocal spell spelllang=en_gb
    endif
  endfunction
endif

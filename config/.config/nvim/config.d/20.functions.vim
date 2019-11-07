" Set the background of the SignColum to transparent
if !exists('*OverrideTheme')
  function! OverrideTheme()
    highlight clear SignColumn
  endfunction
endif

" Enable spell check for certain file types
if !exists('*SetSpellOn')
  function! SetSpellOn(filetype) abort
    if a:filetype == "markdown"
      setlocal spell spelllang=en_gb
    elseif a:filetype == "gitcommit"
      setlocal spell spelllang=en_gb
    endif
  endfunction
endif

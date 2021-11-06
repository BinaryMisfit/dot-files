if !exists('g:vscode')
  set background=dark
  if has('macunix')
    if system("defaults read -g AppleInterfaceStyle") =~ '^Dark'
      set background=dark
    else
      set background=light
    endif
  endif

  let g:gruvbox_italic=1                                  " Enable Italics
  silent! colorscheme gruvbox                             " Set theme to gruvbox
endif

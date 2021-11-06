if !exists('g:vscode')
  if system("defaults read -g AppleInterfaceStyle") =~ '^Dark'
    set background=dark
  else
    set background=light
  endif
  let g:gruvbox_italic=1                                  " Enable Italics
  silent! colorscheme gruvbox                             " Set theme to gruvbox
endif

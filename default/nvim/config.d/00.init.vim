" Check if host os
let host_os='none'
if has('win32')
  let host_os='windows'
elseif has('macunix')
  let host_os='osx'
elseif has('unix')
  let host_os='unix'
endif

" Configure the plugin path
let plugins_path=stdpath('data') . '/plugged'
let plugin_loader=stdpath('config') . '/autoload/plug.vim'

" Download vim-plug if not found
if host_os==#'osx'
  if empty(glob(plugin_loader))
    silent! execute '!curl -fLso ' . plugin_loader . ' --create-dirs '
          \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    augroup syncPlugins
      autocmd VimEnter * PlugInstall --sync | execute 'source ' . stdpath('config')
            \ . '/config.d/10.plugins.vim'
    augroup END
  endif
elseif host_os==#'unix'
  if empty(glob(plugin_loader))
    silent! execute '!curl -fLso ' . plugin_loader . ' --create-dirs '
          \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    augroup syncPlugins
      autocmd VimEnter * PlugInstall --sync | execute 'source ' . stdpath('config')
            \ . '/config.d/10.plugins.vim'
    augroup END
  endif
endif

" Update missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | execute 'source ' . stdpath('config')
            \ . '/config.d/10.plugins.vim'
\| endif

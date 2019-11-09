let g:python_host_prog  = substitute(system('which python2'), '\n', '', 'g')
let g:python3_host_prog  = substitute(system('which python3'), '\n', '', 'g')

for f in split(glob(stdpath('config') . '/config.d/*.vim'), '\n')
    exe 'source' f
endfor

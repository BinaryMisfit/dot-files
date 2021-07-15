let g:loaded_perl_provider = 0
let g:loaded_python_provider = 0
let g:loaded_ruby_provider = 0
let g:python3_host_prog  = substitute(system('which python3'), '\n', '', 'g')

for f in split(glob(stdpath('config') . '/config.d/*.vim'), '\n')
    exe 'source' f
endfor

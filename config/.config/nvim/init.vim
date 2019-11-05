let g:python_host_prog  = '/Library/Frameworks/Python.framework/Versions/2.7/bin/python2'
let g:python3_host_prog = '/Library/Frameworks/Python.framework/Versions/3.8/bin/python3'

for f in split(glob(stdpath('config') . '/config.d/*.vim'), '\n')
    exe 'source' f
endfor

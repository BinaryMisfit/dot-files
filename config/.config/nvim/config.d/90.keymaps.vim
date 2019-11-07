let mapleader=','

cmap w!! w !sudo tee % > /dev/null

nmap <silent> <Leader>/ :let @/=""<CR>

nnoremap <silent> <up> <nop>
nnoremap <silent> <down> <nop>
nnoremap <silent> <left> <nop>
nnoremap <silent> <right> <nop>
nnoremap <silent> <F2> :Startify<CR>
nnoremap <silent> <F3> :UndotreeToggle<CR>
nnoremap <silent> <F5> :source $MYVIMRC<CR>
nnoremap <silent> <F7> :SDelete! Last-Session<CR>
nnoremap <silent> <F8> :SLoad Last-Session<CR>
nnoremap <silent> <F9> :SSave! Last-Session<CR>

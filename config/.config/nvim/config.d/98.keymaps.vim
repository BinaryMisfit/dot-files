" Map the leader key to <space>
let mapleader=' '

" Use w!! to sudowrite
cmap w!! w !sudo tee % > /dev/null<CR>

" Stage files
nnoremap <silent><Leader>gw :Gwrite<CR>
" Git status
nnoremap <silent><Leader>gs :Gstatus<CR>
" Commit staged changes
nnoremap <silent><Leader>gc :Gcommit<CR>
" Push changes to origin
nnoremap <silent><Leader>gp :Gpush<CR>
" Pull changes from origin
nnoremap <silent><Leader>gu :Gpull<CR>

" Disable the <up> key
nnoremap <silent> <up> <nop>
" Disable the down key
nnoremap <silent> <down> <nop>
" Disable the left key
nnoremap <silent> <left> <nop>
" Disable the right key
nnoremap <silent> <right> <nop>

" Use F2 to open startify
nnoremap <silent> <F2> :Startify<CR>
" Use F3 to open Undotree
nnoremap <silent> <F3> :UndotreeToggle<CR>
" Use F5 to reload the configuration
nnoremap <silent> <F5> :source $MYVIMRC<CR>
" Use F7 to delete the current session file
nnoremap <silent> <F7> :SDelete! Last-Session<CR>
" Use F8 to load the last session file
nnoremap <silent> <F8> :SLoad Last-Session<CR>
" Use F9 to save the last session file
nnoremap <silent> <F9> :SSave! Last-Session<CR>

" GoTos
nnoremap <silent><leader>gd :call CocAction('jumpDefinition')<CR>
nnoremap <silent><leader>gl :call CocAction('jumpDeclaration')<CR>
nnoremap <silent><leader>gi :call CocAction('jumpImplementation')<CR>
nnoremap <silent><leader>ge :call CocAction('diagnosticList')<CR>

" Other helpful stuff
nnoremap <silent><leader>ga :call CocAction('codeAction')<CR>
nnoremap <silent><leader>gr :call CocAction('rename')<CR>
nnoremap <silent><leader>gq :call CocAction('quickfixes')<CR>
nnoremap <silent><leader>gh :CocList<CR>

" Show documentation
nnoremap <silent> K :call <SID>show_doc()<CR>

imap <expr><c-space> coc#refresh()
" Prevent <ENTER> moving to newline
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Use <Ctrl> <l> to trigger snippets
imap <C-l> <Plug>(coc-snippets-expand)
" Use <Ctrl> <j> to select text for visual text of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

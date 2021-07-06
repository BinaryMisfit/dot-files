if !exists('g:vscode')
  let g:coc_global_extensions=[
        \'coc-actions',
        \'coc-git',
        \'coc-highlight',
        \'coc-html',
        \'coc-json',
        \'coc-marketplace',
        \'@yaegassy/coc-nginx',
        \'coc-omnisharp',
        \'coc-powershell',
        \'coc-python',
        \'coc-sh',
        \'coc-sql',
        \'coc-vimlsp',
        \'coc-xml',
        \'coc-yaml'
        \]

  function! s:cocActionsOpenFromSelected(type) abort
    execute 'CocCommand actions.open ' . a.type
  endfunction

  xmap <silent> <leader>a :<C-u>execute 'CocCommand actions.open ' . visualmode()<CR>
  nmap <silent> <leader>a :<C-u>set operatorfunc=<SID>cocActionsOpenFromSelected<CR>g@
endif

" Completion, diagnostics, hover and go to definition for Boo in Vim 9,
" through boo-ls and the yegappan/lsp plugin. Neovim reads boo_ls.lua instead.

if has('nvim') || v:version < 900 || exists('g:loaded_boo_ls')
  finish
endif
let g:loaded_boo_ls = 1

" The checkout this file really lives in, when it is linked in by install.sh.
let s:repo = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h:h')

" g:boo_ls_cmd if set, else the boo-ls built in this checkout, else the one on
" PATH (dotnet tool install --global boo-ls).
function! s:Command() abort
  if exists('g:boo_ls_cmd')
    return g:boo_ls_cmd
  endif
  if !empty(glob(s:repo . '/src/boo-ls/bin/*/net10.0/boo-ls', 0, 1))
    return s:repo . '/boo-ls'
  endif
  return exepath('boo-ls')
endfunction

function! s:Warn(message) abort
  augroup boo_ls
    autocmd!
    execute 'autocmd FileType boo ++once echohl WarningMsg | echomsg '
          \ . string('boo: ' . a:message) . ' | echohl None'
  augroup END
endfunction

function! s:Register() abort
  if !exists('*LspAddServer')
    call s:Warn('no completion, no LSP client is set up (see extras/vim/README.md)')
    return
  endif
  let l:cmd = s:Command()
  if empty(l:cmd)
    call s:Warn('no completion, boo-ls is neither built nor on PATH')
    return
  endif
  call LspAddServer([#{
        \ name: 'boo-ls',
        \ filetype: ['boo'],
        \ path: l:cmd,
        \ args: ['--stdio'],
        \ rootSearch: ['.git/'],
        \ }])
endfunction

" install.sh puts the plugin under pack/*/opt. Under pack/*/start it loads
" after this file, and says so with the LspSetup event.
silent! packadd lsp
if exists('*LspAddServer')
  call s:Register()
elseif !empty(globpath(&packpath, 'pack/*/start/lsp', 0, 1))
  autocmd User LspSetup ++once call s:Register()
else
  call s:Register()
endif

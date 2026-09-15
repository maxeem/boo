" Boo indentation.
"
" Boo blocks open with a line ending in a colon and close by dedenting, as in
" Python. Indent after such a line, dedent after a line that leaves its block,
" and pull elif/else/except/ensure/failure back to the block they continue.

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal autoindent
setlocal nolisp nosmartindent nocindent
setlocal indentexpr=GetBooIndent(v:lnum)
setlocal indentkeys=!^F,o,O,<:>,=elif,=else,=except,=ensure,=failure

let b:undo_indent = 'setlocal autoindent< indentexpr< indentkeys< lisp< smartindent< cindent<'

if exists("*GetBooIndent")
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

" The line without a trailing comment or whitespace. Good enough to see a
" colon at the end; a # inside a string on the same line can fool it.
function! s:Code(lnum) abort
  let l:line = getline(a:lnum)
  if has('syntax') && exists('b:current_syntax')
    " Walk back over trailing comment characters the syntax marks as comment.
    let l:col = strlen(l:line)
    while l:col > 0 && synIDattr(synID(a:lnum, l:col, 0), 'name') =~# 'Comment'
      let l:col -= 1
    endwhile
    let l:line = strpart(l:line, 0, l:col)
  endif
  return substitute(l:line, '\s\+$', '', '')
endfunction

function! s:InString(lnum) abort
  return has('syntax') && exists('b:current_syntax')
        \ && synIDattr(synID(a:lnum, 1, 0), 'name') =~# 'String$'
endfunction

function! GetBooIndent(lnum) abort
  let l:prev = prevnonblank(a:lnum - 1)
  if l:prev == 0
    return 0
  endif

  " Leave the insides of multi-line strings alone.
  if s:InString(a:lnum)
    return -1
  endif

  let l:sw = shiftwidth()
  let l:ind = indent(l:prev)
  let l:prevcode = s:Code(l:prev)
  let l:cur = getline(a:lnum)

  if l:prevcode =~# ':$'
    let l:ind += l:sw
  elseif l:prevcode =~# '^\s*\%(return\|pass\|break\|continue\|raise\|goto\)\>'
    let l:ind -= l:sw
  endif

  " A continuation of a block: line it up with the if, try or for it belongs
  " to, found as the nearest such line above not indented deeper than this one.
  if l:cur =~# '^\s*\%(elif\|else\|except\|ensure\|failure\)\>'
    let l:lnum = l:prev
    let l:limit = indent(a:lnum)
    while l:lnum > 0
      let l:text = getline(l:lnum)
      if l:text !~# '^\s*$' && indent(l:lnum) <= l:limit
            \ && l:text =~# '^\s*\%(if\|elif\|unless\|try\|except\|for\|while\)\>'
        return indent(l:lnum)
      endif
      let l:lnum -= 1
    endwhile
    return l:ind - l:sw < 0 ? 0 : l:ind - l:sw
  endif

  return l:ind < 0 ? 0 : l:ind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" Boo filetype settings.

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" Tabs, four columns wide, as .editorconfig asks for *.boo.
setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0

" Comments. commentstring is what gc and friends use to toggle a comment.
setlocal commentstring=#\ %s
setlocal comments=s1:/*,mb:*,ex:*/,://,:#
setlocal formatoptions-=t formatoptions+=croql

" Fold on indentation, but start with everything open.
setlocal foldmethod=indent foldlevel=99

setlocal suffixesadd=.boo
setlocal include=^\\s*\\(from\\\|import\\)
setlocal iskeyword=@,48-57,_,192-255

let b:undo_ftplugin = 'setlocal expandtab< tabstop< shiftwidth< softtabstop<'
      \ . ' commentstring< comments< formatoptions< foldmethod< foldlevel<'
      \ . ' suffixesadd< include< iskeyword<'

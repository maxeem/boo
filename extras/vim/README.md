# Boo in Vim and Neovim

Colors, tab indenting, and completion, hover, diagnostics and go to definition
through `boo-ls`. The same files serve Vim 9 and Neovim 0.11 or later.

```
dotnet build Boo.slnx       # builds boo-ls, which completion needs
extras/vim/install.sh
```

The script links these files into `~/.vim` and `~/.config/nvim`, for whichever
editors are installed, so a `git pull` updates them.

Neovim talks to `boo-ls` with its built-in LSP client. Vim has none, so
completion there needs a plugin: `install.sh --with-lsp` clones
[yegappan/lsp](https://github.com/yegappan/lsp) into `~/.vim/pack/lsp/opt/lsp`,
which `plugin/boo_ls.vim` sets up on its own. With any other client, register
`boo-ls` yourself; see "Another LSP client in Vim" below.

| File | Does |
|---|---|
| `ftdetect/boo.vim` | Sets the filetype for `*.boo` |
| `syntax/boo.vim` | Colors |
| `indent/boo.vim` | Indents after a `:`, dedents after `return`/`pass`/`break`/`continue`/`raise`, lines `else`/`elif`/`except`/`ensure` up with their block |
| `ftplugin/boo.vim` | Tabs four columns wide, comments, indent folding |
| `plugin/boo_ls.vim` | Vim: registers `boo-ls` with yegappan/lsp |
| `plugin/boo_ls.lua` | Neovim: registers `boo-ls` with the built-in client |

## Which boo-ls

The first of:

1. `g:boo_ls_cmd`, if set (`let g:boo_ls_cmd = '/path/to/boo-ls'` or
   `vim.g.boo_ls_cmd = ...` in `init.lua`)
2. the `boo-ls` built in the checkout the files are linked from
3. `boo-ls` on `PATH`, as `dotnet tool install --global boo-ls` puts it

## Using it

In Vim, completions pop up as you type; `<C-n>`/`<C-p>` pick one. `:LspHover`,
`:LspGotoDefinition`, `:LspShowReferences`, `:LspRename` and `:LspDiag show`
do the rest. Map them in your vimrc as you like, for example:

```vim
autocmd FileType boo nnoremap <buffer> gd <Cmd>LspGotoDefinition<CR>
autocmd FileType boo nnoremap <buffer> K <Cmd>LspHover<CR>
```

In Neovim, the LSP mappings you already use apply, and completions come through
the completion plugin you already have.

## Another LSP client in Vim

`plugin/boo_ls.vim` only knows yegappan/lsp. With a different client, tell it to
run `boo-ls --stdio` for the `boo` filetype. For
[vim-lsp](https://github.com/prabirshrestha/vim-lsp):

```vim
autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'boo-ls',
      \ 'cmd': {server_info -> ['boo-ls', '--stdio']},
      \ 'allowlist': ['boo'],
      \ })
```

For [coc.nvim](https://github.com/neoclide/coc.nvim), in `coc-settings.json`:

```json
{
  "languageserver": {
    "boo": {
      "command": "boo-ls",
      "args": ["--stdio"],
      "filetypes": ["boo"]
    }
  }
}
```

Use the full path to `boo-ls` where it is not on `PATH`.

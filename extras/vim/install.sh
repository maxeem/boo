#!/bin/sh
# Links the Boo support in this directory into Vim and Neovim, so a git pull
# updates it.
#
#   extras/vim/install.sh              # both editors, whichever are installed
#   extras/vim/install.sh --with-lsp   # and clone yegappan/lsp, which Vim
#                                      # needs for completion. Neovim does not.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
lsp=no
[ "${1:-}" = "--with-lsp" ] && lsp=yes

files="ftdetect/boo.vim syntax/boo.vim indent/boo.vim ftplugin/boo.vim
plugin/boo_ls.vim plugin/boo_ls.lua"

link_into() {
	target=$1
	for f in $files; do
		dest="$target/$f"
		mkdir -p "$(dirname "$dest")"
		if [ -e "$dest" ] && [ ! -L "$dest" ]; then
			echo "skipped $dest: a file that is not ours is already there" >&2
			continue
		fi
		ln -sfn "$here/$f" "$dest"
	done
	echo "linked into $target"
}

if command -v vim >/dev/null 2>&1; then
	link_into "$HOME/.vim"
	if ls -d "$HOME"/.vim/pack/*/*/lsp >/dev/null 2>&1; then
		:
	elif [ $lsp = yes ]; then
		git clone --depth 1 https://github.com/yegappan/lsp "$HOME/.vim/pack/lsp/opt/lsp"
		vim -u NONE -Nes -c "helptags $HOME/.vim/pack/lsp/opt/lsp/doc" -c q </dev/null >/dev/null 2>&1 || true
	else
		echo "Vim needs an LSP client for completion: rerun with --with-lsp,"
		echo "or set up boo-ls in the one you use (see extras/vim/README.md)."
	fi
fi

if command -v nvim >/dev/null 2>&1; then
	link_into "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
fi

repo=$(cd "$here/../.." && pwd)
if ls "$repo"/src/boo-ls/bin/*/net10.0/boo-ls >/dev/null 2>&1; then
	echo "completion will use $repo/boo-ls"
elif command -v boo-ls >/dev/null 2>&1; then
	echo "completion will use $(command -v boo-ls)"
else
	echo "boo-ls is not built yet, so there is no completion until you run:" >&2
	echo "  dotnet build $repo/Boo.slnx" >&2
fi

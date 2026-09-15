-- Completion, diagnostics, hover and go to definition for Boo in Neovim,
-- through boo-ls and the built-in LSP client. Vim reads boo_ls.vim instead.

if vim.g.loaded_boo_ls or vim.fn.has("nvim-0.11") == 0 then
  return
end
vim.g.loaded_boo_ls = true

-- The checkout this file really lives in, when it is linked in by install.sh.
local this = vim.fn.resolve(debug.getinfo(1, "S").source:sub(2))
local repo = vim.fn.fnamemodify(this, ":p:h:h:h:h")

-- vim.g.boo_ls_cmd if set, else the boo-ls built in this checkout, else the one
-- on PATH (dotnet tool install --global boo-ls).
local function command()
  if vim.g.boo_ls_cmd then
    return vim.g.boo_ls_cmd
  end
  if #vim.fn.glob(repo .. "/src/boo-ls/bin/*/net10.0/boo-ls", false, true) > 0 then
    return repo .. "/boo-ls"
  end
  return vim.fn.exepath("boo-ls")
end

local cmd = command()
if cmd == "" then
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "boo",
    once = true,
    callback = function()
      vim.notify("boo: no completion, boo-ls is neither built nor on PATH", vim.log.levels.WARN)
    end,
  })
  return
end

vim.lsp.config("boo_ls", {
  cmd = { cmd, "--stdio" },
  filetypes = { "boo" },
  root_markers = { ".git" },
})
vim.lsp.enable("boo_ls")

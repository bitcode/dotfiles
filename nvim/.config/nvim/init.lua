-- To prevent warnings about undefined `vim` global variable
if _G.vim == nil then _G.vim = {} end
require("utils")
--require("copilot").setup({})
--require("toggleterm-config")
--require("lsp_lua")
require("lspkind")
require("plugins")
--require("neodev")
require("config")
require("config.colorscheme")
require("config.completion")
require("config.fugitive")
require("lualine-config")
require("settings")
require("lualine").setup()
require("whichkey-config")
require("telescope")
require("telescope-config")
require("telescope-file-browser-config")
--require('telescope').load_extension('projects')
--require('telescope').load_extension('metacode_ai')
require("lspconfig").pylsp.setup({})
require("lspconfig").clangd.setup({})
require("lspconfig").gopls.setup({})
require("lspconfig").bashls.setup({})
require("lspconfig").cssls.setup({})
require("lspconfig").html.setup({})
require("lspconfig").tsserver.setup({})
require("lspconfig").emmet_ls.setup({})
require("lspconfig").pyright.setup({})
--require("lspconfig").lua_ls.setup({})
require("lspconfig").rust_analyzer.setup({})
require("cmp").setup({
	sources = {
		{ name = "nvim-lsp" },
		{ name = "buffer" },
		{ name = "path" },
		{ name = "cmdline" },
		{ name = "nvim_lsp_document_symbol" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "spell" },
		{ name = "calc" },
		{ name = "emoji" },
		{ name = "nvim-lua" },
		{ name = "copilot" },
	},
})
require("gitsigns").setup()
require("gitsigns-config")
--require("cmp-config")
require("mason").setup()
require("mason-lspconfig").setup{
    ensure_installed = {"rust_analyzer", "lua_ls", "emmet_ls", "tsserver", "html", "cssls", "bashls", "pylsp", "clangd", "gopls"},
}
require("null-ls").setup({
	sources = {
		require("null-ls").builtins.formatting.prettier,
		require("null-ls").builtins.formatting.stylua,
		require("null-ls").builtins.diagnostics.eslint,
	},
})
require("nvim-autopairs").setup({})
require("null-ls-config")
require("cmp_nvim_lsp")
require("toggleterm").setup()
require("cmp").setup.cmdline(":", {
	sources = {
		{ name = "cmdline" },
		{ name = "nvim_lsp_document_symbol" },
	},
})
require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
require "lsp_signature".setup()
-- set directory to the current file's directory
vim.cmd([[
  augroup auto_change_directory
    autocmd!
    autocmd VimEnter * if argc() == 0 | lcd %:p:h | endif
    autocmd BufEnter * lcd %:p:h
  augroup END
]])
--vim.cmd("command! MetaCodeAITelescope lua require('metacode_ai_telescope').metacode_ai_picker()")
--vim.api.nvim_set_keymap('n', '<leader>m', ':MetaCodeAITelescope<CR>', {noremap = true, silent = true})

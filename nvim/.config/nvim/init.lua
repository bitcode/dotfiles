-- To prevent warnings about undefined `vim` global variable
if _G.vim == nil then _G.vim = {} end
require("utils") -- use to configure global, local, current windows
--require("copilot").setup({}) copilot works without this line
require("toggleterm-config") -- terminal
require'nvim-treesitter.configs'.setup {
  autotag = {
    enable = true,
  }
}
require("lsp_lua") -- global lsp configuration
require("lspkind") -- lsp icons
require("plugins") -- packer plugins
--require("neodev") -- signature lua lsp
require("config") -- loads 4 config files 
require("config.colorscheme")
require("lualine-config") -- statusline
require("settings") -- nvim regular settings, view utils 
require("lualine").setup() -- statusline
require("whichkey-config") -- keybindings
require("telescope")
require("telescope-config") -- fuzzy finder config
require("telescope-file-browser-config") -- file browser
require('telescope').load_extension('projects')
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
require("lspconfig").lua_ls.setup({})
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
require("cmp-config")
require("mason").setup()
require("mason-lspconfig").setup{
    ensure_installed = {"rust_analyzer","pylsp", "lua_ls", "emmet_ls", "tsserver", "cssls", "bashls", "clangd", "gopls"},
}
require("null-ls").setup({
	sources = {
		require("null-ls").builtins.formatting.prettier,
		require("null-ls").builtins.formatting.stylua,
		require("null-ls").builtins.diagnostics.eslint,
	},
})
require("nvim-ts-autotag")
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

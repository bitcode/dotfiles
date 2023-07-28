-- File: config/init.lua

-- Ensure packer is installed and added to runtimepath
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	use({
		"neovim/nvim-lspconfig", -- Configurations for Nvim LSP
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	})
    use('windwp/nvim-ts-autotag')
	use({ "sainnhe/gruvbox-material" })
	--	use({ "styled-components/vim-styled-components" })
	use({
		"ray-x/lsp_signature.nvim",
	})
	use({ "wbthomason/packer.nvim" })
	use({ "themercorp/themer.lua" })
	use({ "folke/which-key.nvim" })
	use({ "akinsho/toggleterm.nvim" })
	use({
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	})
	use({ "kyazdani42/nvim-web-devicons" })
	use({
		"jackMort/ChatGPT.nvim",
		config = function()
			require("chatgpt").setup({
				-- optional configuration
			})
		end,
		requires = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
	})
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
	})
	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
	})
	use({
		"folke/zen-mode.nvim",
	})
	use({ "L3MON4D3/LuaSnip" })
	use({ "saadparwaiz1/cmp_luasnip" })
	use({
		"zbirenbaum/copilot.lua",
		event = "VimEnter",
		config = function()
			vim.defer_fn(function()
				require("copilot").setup()
			end, 100)
		end,
	})
	use({
		"zbirenbaum/copilot-cmp",
		after = { "copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end,
	})
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-cmdline" },
			{ "f3fora/cmp-spell", { "hrsh7th/cmp-calc" }, { "hrsh7th/cmp-emoji" } },
		},
	})
	use({ "lewis6991/gitsigns.nvim" })
	use({ "p00f/nvim-ts-rainbow" })
	use({ "jose-elias-alvarez/null-ls.nvim" })
	use({ "onsails/lspkind-nvim", requires = { { "famiu/bufdelete.nvim" } } })
	use({ "nvim-telescope/telescope-file-browser.nvim" })
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		-- or                            , branch = '0.1.x',
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
	})
--   use {
--   'bitcode/metacode_ai',
--    branch = 'master',
--   requires = {'nvim-telescope/telescope.nvim'},
--   config = function()
--       require('telescope').load_extension('metacode_ai')
--   end,
--   post_install = function()
--      local plugin_dir = vim.fn.stdpath('data')..'/site/pack/packer/start/metacode_ai/python'
--      vim.fn.system('pip install --user .', plugin_dir)
--    end,
--  }
	use({ "hrsh7th/cmp-nvim-lsp-signature-help" })
	use({
		"windwp/nvim-autopairs",
		config = function()
		require("nvim-autopairs").setup({})
		end,
	})
end)

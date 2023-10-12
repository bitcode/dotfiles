local function load_plugins()
	return  { 
		"neovim/nvim-lspconfig", -- Configurations for Nvim LSP
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"sainnhe/gruvbox-material", 
		"ray-x/lsp_signature.nvim",
		"themercorp/themer.lua",
		"folke/which-key.nvim",
		"akinsho/toggleterm.nvim",
		"folke/zen-mode.nvim",
		"kyazdani42/nvim-web-devicons",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "kyazdani42/nvim-web-devicons" },
			event = 'BufEnter',
			config = function()
				require('lualine').setup{}
			local colors = {
			  bg       = '#202328',
			  fg       = '#bbc2cf',
			  yellow   = '#ECBE7B',
			  cyan     = '#008080',
			  darkblue = '#081633',
			  green    = '#98be65',
			  orange   = '#FF8800',
			  violet   = '#a9a1e1',
			  magenta  = '#c678dd',
			  blue     = '#51afef',
			  red      = '#ec5f67',
			}
		end	
		},
		{
			"folke/trouble.nvim",
			dependencies = { "kyazdani42/nvim-web-devicons" },
			lazy = true,
		},
		{
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				{ "hrsh7th/cmp-nvim-lsp" },
				{ "hrsh7th/cmp-nvim-lua" },
				{ "hrsh7th/cmp-buffer" },
				{ "hrsh7th/cmp-path" },
				{ "hrsh7th/cmp-cmdline" },
				{ "f3fora/cmp-spell", },
				{ "hrsh7th/cmp-calc" },
				{ "hrsh7th/cmp-emoji" }, 
				},
		},
		"lewis6991/gitsigns.nvim",
		"jose-elias-alvarez/null-ls.nvim",
		{
		"onsails/lspkind-nvim", dependencies = { "famiu/bufdelete.nvim" },
		},
		"nvim-telescope/telescope-file-browser.nvim",
		{
			"nvim-telescope/telescope.nvim",
			version = "0.1.0",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		"hrsh7th/cmp-nvim-lsp-signature-help",
		{
			'windwp/nvim-autopairs',
	    		event = "InsertEnter",
		},
	}
end

	return { load_plugins = load_plugins }		

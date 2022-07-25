-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
    use { 'sainnhe/gruvbox-material' }
    use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'}
    use { 'nvim-lua/completion-nvim' }
    use { 'tjdevries/nlua.nvim' }
    use "folke/lua-dev.nvim" -- fix Sumneko 
    use({ "wbthomason/packer.nvim" })
    use { "themercorp/themer.lua"}
    use({ "folke/which-key.nvim" })
    use({ "akinsho/bufferline.nvim", requires = "kyazdani42/nvim-web-devicons"})
    use({ "akinsho/toggleterm.nvim" })
    use({ "ahmedkhalf/project.nvim" })
    use({ "kyazdani42/nvim-web-devicons" })
    use({
      "nvim-lualine/lualine.nvim",
      event = "VimEnter",
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
    use({
      "norcalli/nvim-colorizer.lua",
      event = "BufReadPre",
    })
    use({
      "windwp/nvim-autopairs",
      after = "nvim-cmp",
    })
    use({
      "hrsh7th/nvim-cmp",
      requires = {
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-nvim-lua" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-path" },
        { "hrsh7th/cmp-cmdline" },
        { "hrsh7th/vim-vsnip" },
        { "hrsh7th/cmp-vsnip" },
        { "hrsh7th/vim-vsnip-integ" },
        { "f3fora/cmp-spell", { "hrsh7th/cmp-calc" }, { "hrsh7th/cmp-emoji" } },
        { "rafamadriz/friendly-snippets" },
      },
    })
    use({ "kyazdani42/nvim-tree.lua" })
    use({
      "rlane/pounce.nvim",
    })
    use({
      "lewis6991/gitsigns.nvim",
      requires = { "nvim-lua/plenary.nvim" },
      event = "BufReadPre",
    })

    use({ "p00f/nvim-ts-rainbow" })

    use({ "jose-elias-alvarez/null-ls.nvim" })
    use({ "williamboman/nvim-lsp-installer" })
    use({
      "numToStr/Comment.nvim",
      opt = true,
      keys = { "gc", "gcc" },
    })
    use({ "onsails/lspkind-nvim", requires = { { "famiu/bufdelete.nvim" } } })
    use({ "tpope/vim-repeat" })
    use({ "tpope/vim-surround" })
    use({ "wellle/targets.vim" })
    use({ "filipdutescu/renamer.nvim" })
    use({ "goolord/alpha-nvim" })
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    }
    use({ "luukvbaal/stabilize.nvim" })
end)

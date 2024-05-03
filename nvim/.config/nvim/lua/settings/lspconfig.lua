-- Setup language servers.
local lspconfig = require('lspconfig')

-- Server configurations
lspconfig.pyright.setup {}
lspconfig.tsserver.setup {
  settings = {
    typescript = {
      format = {
        enable = true,
      },
    },
  },
}
lspconfig.lua_ls.setup {
  on_attach = function(client, bufnr)
    require('completion').on_attach(client, bufnr)
    config.on_attach(client, bufnr)
    client.server_capabilities.documentFormatProvider = true
    client.server_capabilities.documentRangeFormatProvider = true
  end,
  settings = {
    Lua = {
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        }
      },
    },
  },
}
-- Additional language server setups...
lspconfig.cssmodules_ls.setup {}
lspconfig.bashls.setup {}
lspconfig.dockerls.setup {}
lspconfig.emmet_language_server.setup {}
lspconfig.html.setup {}
lspconfig.pylsp.setup {}
lspconfig.asm_lsp.setup{
  cmd = { "asm-lsp" },
  filetypes = { "asm", "s", "S" },
  root_dir = lspconfig.util.root_pattern(".git", ".asm-lsp.toml"),
  settings = {
    version = "0.1",
    assemblers = {
      gas = true,
      go = false
    },
    instruction_sets = {
      x86 = false,
      x86_64 = true
    }
  },
  on_attach = function(client, bufnr)
    require('completion').on_attach(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap=true, silent=true }
    -- Key mappings for LSP functions
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  end,
  flags = {
    debounce_text_changes = 150,
  }
}
lspconfig.tailwinds.setup {}
lspconfig.gopls.setup {}
lspconfig.htmx.setup {}
lspconfig.clangd.setup {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "-j4",
    "--fallback-style=llvm",
    "--all-scopes-completion",
    "--suggest-missing-includes",
    "--log=info"
  },
  root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git", "Makefile"),
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  on_attach = function(client, bufnr)
    require('completion').on_attach(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  end,
  flags = {
    debounce_text_changes = 150,
  }
}
lspconfig.rust_analyzer.setup {
  settings = {
    ['rust-analyzer'] = {},
  },
}

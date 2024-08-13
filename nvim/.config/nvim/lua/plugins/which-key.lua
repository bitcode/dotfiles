return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    local which_key = require('which-key')
    which_key.setup {
      notify = false,
    }

    -- GitGutter keybindings
    local gitgutter_mappings = {
      gP = { "<cmd>GitGutterPreviewHunk<CR>", "Preview Hunk" },
      gs = { "<cmd>GitGutterStageHunk<CR>", "Stage Hunk" },
      gp = { "<cmd>GitGutterPrevHunk<CR>", "Previous Hunk" },
      gn = { "<cmd>GitGutterNextHunk<CR>", "Next Hunk" },
      gu = { "<cmd>GitGutterUndoHunk<CR>", "Undo Hunk" },
    }
    which_key.register(gitgutter_mappings, { prefix = "<leader>g" })

    -- Window management keybindings
    local window_mappings = {
      ["+"] = { "<C-w>+", "Increase height" },
      ["-"] = { "<C-w>-", "Decrease height" },
      ["<"] = { "<C-w><", "Decrease width" },
      ["="] = { "<C-w>=", "Equalize window sizes" },
      [">"] = { "<C-w>>", "Increase width" },
      T = { "<C-w>T", "Break out into tab" },
      _ = { "<C-w>_", "Maximize height" },
      c = { "<C-w>c", "Close other windows" },
      h = { "<C-w>h", "Left window" },
      j = { "<C-w>j", "Below window" },
      k = { "<C-w>k", "Above window" },
      l = { "<C-w>l", "Right window" },
      o = { "<C-w>o", "Close other windows" },
      q = { "<C-w>q", "Close window" },
      r = { "<C-w>r", "Rotate windows downwards/rightwards" },
      s = { "<C-w>s", "Split horizontally" },
      v = { "<C-w>v", "Split vertically" },
      w = { "<C-w>w", "Other window" },
    }
    which_key.register(window_mappings, { prefix = "<C-p>" })

        local lsp_mappings = {
      l = {
        name = "LSP",
        d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Go to Definition" },
        r = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
        i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Go to Implementation" },
        h = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover" },
        s = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature Help" },
        n = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
        a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
        f = { "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", "Format" },
        t = { "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Type Definition" },

        -- Diagnostics-related commands
        e = { "<cmd>lua vim.diagnostic.open_float()<CR>", "Show Diagnostics" },
        q = { "<cmd>lua vim.diagnostic.setqflist()<CR>", "Diagnostics to Quickfix" },
        l = { "<cmd>lua vim.diagnostic.setloclist()<CR>", "Diagnostics to LocList" },
        j = { "<cmd>lua vim.diagnostic.goto_next()<CR>", "Next Diagnostic" },
        k = { "<cmd>lua vim.diagnostic.goto_prev()<CR>", "Previous Diagnostic" },
      }
    }
    which_key.register(lsp_mappings, { prefix = "<leader>" })

    -- Telescope keybindings
    local telescope_mappings = {
      ff = { "<cmd>Telescope find_files<cr>", "Find Files" },
      fg = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
      fb = { "<cmd>Telescope buffers<cr>", "List Buffers" },
      fh = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
      fx = { "<cmd>Telescope find_files<cr>", "Find Files" },
      ["fx<C-v>"] = { "<cmd>Telescope select_vertical<cr>", "Select Vertical" },
      ["fx<C-x>"] = { "<cmd>Telescope select_horizontal<cr>", "Select Horizontal" },
    }
    which_key.register(telescope_mappings, { prefix = "<leader>" })

    -- DevDocs keybindings
    local devdocs_mappings = {
      fz = { "<cmd>DevdocsOpenCurrentFloat<CR>", "Devdocs Open Current Float" },
    }
    which_key.register(devdocs_mappings, { prefix = "<leader>" })

    -- Oil.nvim keybindings
    local oil_mappings = {
      of = { ":lua require('oil').open_float()<CR>", "Open Oil Float" },
      ot = { ":lua require('oil').toggle_float()<CR>", "Toggle Oil Float" },
      oc = { ":lua require('oil').close()<CR>", "Close Oil Window" },
    }
    which_key.register(oil_mappings, { prefix = "<leader>" })

    -- Floaterm keybindings
    local floaterm_mappings = {
      fn = { ":FloatermNew<CR>", "New Floaterm" },
      fp = { ":FloatermPrev<CR>", "Previous Floaterm" },
      ft = { ":FloatermToggle<CR>", "Toggle Floaterm" },
      fx = { ":FloatermKill<CR>", "Close Floaterm" },
      fc = { ":FloatermNew bash -c 'gcc % && ./a.out; echo Press ENTER to close; read'<CR>", "Compile & Run" },
    }
    which_key.register(floaterm_mappings, { prefix = "<leader>" })

    -- Harpoon keybindings
    local harpoon_mappings = {
      ha = { ":lua require('harpoon.ui').add_file()<CR>", "Add File" },
      hr = { ":lua require('harpoon.ui').remove_file()<CR>", "Remove File" },
      hc = { ":lua require('harpoon.term').sendCommand(1, 'ls -La')<CR>", "Send Command" },
      ui = { ":lua require('harpoon.ui').toggle_quick_menu()<CR>", "Toggle Quick Menu" },
      m = { ":lua require('harpoon.mark').add_mark()<CR>", "Add Mark" },
      jn = { ":lua require('harpoon.ui').next_buffer()<CR>", "Next Buffer" },
      jp = { ":lua require('harpoon.ui').prev_buffer()<CR>", "Previous Buffer" },
    }
    which_key.register(harpoon_mappings, { prefix = "<leader>" })

    -- New line keybindings
    local new_line_mappings = {
      ["<CR>"] = { 'm`o<Esc>``', "New line below" },
      ["<S-CR>"] = { 'm`O<Esc>``', "New line above" },
    }
    which_key.register(new_line_mappings, { prefix = "<Leader>" })
  end,
}

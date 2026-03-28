return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    config = function()
        local wk = require('which-key')

        -- Enhanced setup with modern configuration
        wk.setup({
            preset = "modern",
            delay = 0, -- Show immediately for comprehensive visibility
            expand = 1, -- Expand groups with <= 1 mappings
            notify = false,
            plugins = {
                marks = true,
                registers = true,
                spelling = {
                    enabled = true,
                    suggestions = 20,
                },
                presets = {
                    operators = true,
                    motions = true,
                    text_objects = true,
                    windows = true,
                    nav = true,
                    z = true,
                    g = true,
                },
            },
            win = {
                border = "rounded",
                padding = { 1, 2 },
                title = true,
                title_pos = "center",
            },
            layout = {
                width = { min = 20, max = 50 },
                spacing = 3,
            },
            sort = { "local", "order", "group", "alphanum", "mod" },
            icons = {
                breadcrumb = "»",
                separator = "➜",
                group = "+",
                ellipsis = "…",
                mappings = true,
                rules = {},
                colors = true,
            },
            show_help = true,
            show_keys = true,
        })

        -- ============================================================================
        -- COMPREHENSIVE KEYBINDING MAPPINGS
        -- ============================================================================

        -- Main leader key mappings with complete coverage
        wk.add({
            -- ========================================================================
            -- FILE OPERATIONS & TELESCOPE
            -- ========================================================================
            { "<leader>f", group = "📁 Files & Search", icon = "📁" },
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files", icon = "🔍" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep", icon = "🔎" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "List Buffers", icon = "📋" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags", icon = "❓" },
            { "<leader>fx", "<cmd>Telescope find_files<cr>", desc = "Find Files (Alt)", icon = "🔍" },
            { "<leader>fz", "<cmd>DevdocsOpenCurrentFloat<CR>", desc = "DevDocs Float", icon = "📚" },

            -- ========================================================================
            -- LSP OPERATIONS
            -- ========================================================================
            { "<leader>l", group = "🔧 LSP & Language", icon = "🔧" },
            { "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "Go to Definition", icon = "📍" },
            { "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<CR>", desc = "Go to Declaration", icon = "📍" },
            { "<leader>lr", "<cmd>lua vim.lsp.buf.references()<CR>", desc = "References", icon = "🔗" },
            { "<leader>li", "<cmd>lua vim.lsp.buf.implementation()<CR>", desc = "Go to Implementation", icon = "🎯" },
            { "<leader>lh", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "Hover Info", icon = "💡" },
            { "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", desc = "Signature Help", icon = "✍️" },
            { "<leader>ln", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Rename Symbol", icon = "✏️" },
            { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "Code Actions", icon = "⚡" },
            { "<leader>lf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", desc = "Format Code", icon = "🎨" },
            { "<leader>lt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", desc = "Type Definition", icon = "🏷️" },

            -- LSP Diagnostics
            { "<leader>le", "<cmd>lua vim.diagnostic.open_float()<CR>", desc = "Show Diagnostics", icon = "🚨" },
            { "<leader>lq", "<cmd>lua vim.diagnostic.setqflist()<CR>", desc = "Diagnostics to Quickfix", icon = "📝" },
            { "<leader>ll", "<cmd>lua vim.diagnostic.setloclist()<CR>", desc = "Diagnostics to LocList", icon = "📋" },
            { "<leader>lj", "<cmd>lua vim.diagnostic.goto_next()<CR>", desc = "Next Diagnostic", icon = "⬇️" },
            { "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev()<CR>", desc = "Previous Diagnostic", icon = "⬆️" },

            -- ========================================================================
            -- LSP WORKSPACE & SYMBOLS (New keybindings from lspconfig.lua)
            -- ========================================================================
            { "<leader>w", group = "🌐 Workspace", icon = "🌐" },
            { "<leader>ws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", desc = "Workspace Symbols", icon = "🔍" },

            { "<leader>d", group = "📄 Document", icon = "📄" },
            { "<leader>ds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", desc = "Document Symbols", icon = "📋" },

            -- Additional LSP shortcuts that match lspconfig.lua keybindings
            -- Note: These are duplicates of the <leader>l* versions above for convenience
            { "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Rename Symbol", icon = "✏️" },
            { "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "Code Actions", icon = "⚡" },
            -- Note: <leader>f conflicts with Files group, use <leader>lf instead
            -- Note: <leader>e and <leader>q would conflict with other potential uses
            -- These keybindings are available through the <leader>l* versions above

            -- ========================================================================
            -- GIT OPERATIONS
            -- ========================================================================
            { "<leader>g", group = "🔀 Git Operations", icon = "🔀" },
            { "<leader>gP", "<cmd>GitGutterPreviewHunk<CR>", desc = "Preview Hunk", icon = "👁️" },
            { "<leader>gs", "<cmd>GitGutterStageHunk<CR>", desc = "Stage Hunk", icon = "➕" },
            { "<leader>gp", "<cmd>GitGutterPrevHunk<CR>", desc = "Previous Hunk", icon = "⬆️" },
            { "<leader>gn", "<cmd>GitGutterNextHunk<CR>", desc = "Next Hunk", icon = "⬇️" },
            { "<leader>gu", "<cmd>GitGutterUndoHunk<CR>", desc = "Undo Hunk", icon = "↩️" },

            -- ========================================================================
            -- FILE MANAGER (OIL)
            -- ========================================================================
            { "<leader>o", group = "📂 File Manager", icon = "📂" },
            { "<leader>of", ":lua require('oil').open_float()<CR>", desc = "Open Oil Float", icon = "🎈" },
            { "<leader>ot", ":lua require('oil').toggle_float()<CR>", desc = "Toggle Oil Float", icon = "🔄" },
            { "<leader>oc", ":lua require('oil').close()<CR>", desc = "Close Oil Window", icon = "❌" },

            -- ========================================================================
            -- TERMINAL (FLOATERM)
            -- ========================================================================
            { "<leader>t", group = "💻 Terminal", icon = "💻" },
            { "<leader>tn", ":FloatermNew<CR>", desc = "New Terminal", icon = "➕" },
            { "<leader>tt", ":FloatermToggle<CR>", desc = "Toggle Terminal", icon = "🔄" },
            { "<leader>tT", ":FloatermToggle!<CR>", desc = "Toggle All Terminals", icon = "🔄" },
            { "<leader>t]", ":FloatermNext<CR>", desc = "Next Terminal", icon = "➡️" },
            { "<leader>t[", ":FloatermPrev<CR>", desc = "Previous Terminal", icon = "⬅️" },
            { "<leader>tx", ":FloatermKill<CR>", desc = "Kill Terminal", icon = "❌" },
            { "<leader>tX", ":FloatermKill!<CR>", desc = "Kill All Terminals", icon = "❌" },
            { "<leader>tc", ":FloatermRun<CR>", desc = "Compile & Run File", icon = "⚡" },
            { "<leader>ts", ":'<,'>FloatermSend<CR>", desc = "Send Selection", icon = "📤", mode = "v" },
            { "<leader>tg", ":FloatermLazygit<CR>", desc = "Lazygit", icon = "🔀" },
            { "<leader>tp", ":FloatermPython<CR>", desc = "Python REPL", icon = "🐍" },
            { "<leader>tj", ":FloatermNode<CR>", desc = "Node REPL", icon = "📦" },

            -- ========================================================================
            -- HARPOON NAVIGATION
            -- ========================================================================
            { "<leader>h", group = "🎯 Harpoon", icon = "🎯" },
            { "<leader>ha", ":lua require('harpoon.ui').add_file()<CR>", desc = "Add File", icon = "➕" },
            { "<leader>hr", ":lua require('harpoon.ui').remove_file()<CR>", desc = "Remove File", icon = "➖" },
            { "<leader>hc", ":lua require('harpoon.term').sendCommand(1, 'ls -La')<CR>", desc = "Send Command", icon = "📤" },
            { "<leader>ui", ":lua require('harpoon.ui').toggle_quick_menu()<CR>", desc = "Toggle Quick Menu", icon = "📋" },
            { "<leader>m", ":lua require('harpoon.mark').add_mark()<CR>", desc = "Add Mark", icon = "🔖" },
            { "<leader>jn", ":lua require('harpoon.ui').next_buffer()<CR>", desc = "Next Buffer", icon = "⏭️" },
            { "<leader>jp", ":lua require('harpoon.ui').prev_buffer()<CR>", desc = "Previous Buffer", icon = "⏮️" },

            -- ========================================================================
            -- CLAUDE CODE
            -- ========================================================================
            { "<leader>c",   group = "🤖 Claude Code",          icon = "🤖" },
            { "<leader>cc",  "<cmd>ClaudeCode<CR>",              desc = "Toggle Claude",         icon = "🤖" },
            { "<leader>cf",  "<cmd>ClaudeCodeFocus<CR>",         desc = "Focus Claude",          icon = "🎯" },
            { "<leader>cr",  "<cmd>ClaudeCode --resume<CR>",     desc = "Resume session",        icon = "▶️" },
            { "<leader>cC",  "<cmd>ClaudeCode --continue<CR>",   desc = "Continue session",      icon = "⏩" },
            { "<leader>cm",  "<cmd>ClaudeCodeSelectModel<CR>",   desc = "Select model",          icon = "🧠" },
            { "<leader>cb",  "<cmd>ClaudeCodeAdd %<CR>",         desc = "Add buffer to context", icon = "📎" },
            { "<leader>cs",  "<cmd>ClaudeCodeSend<CR>",          desc = "Send selection",        icon = "📤", mode = "v" },
            { "<leader>ca",  "<cmd>ClaudeCodeDiffAccept<CR>",    desc = "Accept diff",           icon = "✅" },
            { "<leader>cd",  "<cmd>ClaudeCodeDiffDeny<CR>",      desc = "Deny diff",             icon = "❌" },

            -- ========================================================================
            -- ASSEMBLY DEVELOPMENT (ASM-LSP)
            -- ========================================================================
            { "<leader>a", group = "⚙️ Assembly", icon = "⚙️" },
            { "<leader>ad", "<cmd>lua require('custom_arm_docs').open_arm_docs_for_word()<CR>", desc = "ARM Docs for Word", icon = "📖" },
            { "<leader>ai", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "Instruction Info", icon = "ℹ️" },
            { "<leader>ar", "<cmd>lua vim.lsp.buf.references()<CR>", desc = "Label References", icon = "🔗" },
            { "<leader>ac", "<cmd>lua require('asm_utils').create_project_config()<CR>", desc = "Create Project Config", icon = "⚙️" },
            { "<leader>at", "<cmd>lua require('asm_utils').toggle_architecture()<CR>", desc = "Toggle Architecture", icon = "🔄" },
            { "<leader>as", "<cmd>lua require('asm_utils').show_snippets()<CR>", desc = "Show Snippets", icon = "📝" },

            -- ========================================================================
            -- UTILITY & EDITING
            -- ========================================================================
            { "<leader>u", group = "🛠️ Utilities", icon = "🛠️" },
            { "<leader><CR>", "m`o<Esc>``", desc = "New Line Below", icon = "⬇️" },
            { "<leader><S-CR>", "m`O<Esc>``", desc = "New Line Above", icon = "⬆️" },
        })

        -- ========================================================================
        -- WINDOW MANAGEMENT (Ctrl+P prefix)
        -- ========================================================================
        wk.add({
            { "<C-p>", group = "🪟 Window Management", icon = "🪟" },
            { "<C-p>+", "<C-w>+", desc = "Increase Height", icon = "📏" },
            { "<C-p>-", "<C-w>-", desc = "Decrease Height", icon = "📐" },
            { "<C-p><", "<C-w><", desc = "Decrease Width", icon = "↔️" },
            { "<C-p>=", "<C-w>=", desc = "Equalize Sizes", icon = "⚖️" },
            { "<C-p>>", "<C-w>>", desc = "Increase Width", icon = "↔️" },
            { "<C-p>T", "<C-w>T", desc = "Break to Tab", icon = "📑" },
            { "<C-p>_", "<C-w>_", desc = "Maximize Height", icon = "📏" },
            { "<C-p>c", "<C-w>c", desc = "Close Window", icon = "❌" },
            { "<C-p>h", "<C-w>h", desc = "Left Window", icon = "⬅️" },
            { "<C-p>j", "<C-w>j", desc = "Below Window", icon = "⬇️" },
            { "<C-p>k", "<C-w>k", desc = "Above Window", icon = "⬆️" },
            { "<C-p>l", "<C-w>l", desc = "Right Window", icon = "➡️" },
            { "<C-p>o", "<C-w>o", desc = "Close Others", icon = "🗑️" },
            { "<C-p>q", "<C-w>q", desc = "Quit Window", icon = "🚪" },
            { "<C-p>r", "<C-w>r", desc = "Rotate Windows", icon = "🔄" },
            { "<C-p>s", "<C-w>s", desc = "Split Horizontal", icon = "➖" },
            { "<C-p>v", "<C-w>v", desc = "Split Vertical", icon = "➗" },
            { "<C-p>w", "<C-w>w", desc = "Other Window", icon = "🔄" },
        })

        -- ========================================================================
        -- BUILT-IN NEOVIM KEYBINDINGS (Non-leader)
        -- ========================================================================
        wk.add({
            -- LSP Navigation & Documentation
            { "g", group = "🧭 Go/Navigation" },
            { "gd", desc = "Go to Definition" },
            { "gD", desc = "Go to Declaration" },
            { "gt", desc = "Go to Type Definition" },
            { "gi", desc = "Go to Implementation" },
            { "gr", desc = "Go to References" },
            { "K", desc = "Hover Documentation" },

            -- Signature Help
            { "<C-k>", desc = "Signature Help", mode = { "n", "i" } },

            -- Diagnostic Navigation
            { "[", group = "⬅️ Previous" },
            { "[d", desc = "Previous Diagnostic" },
            { "]", group = "➡️ Next" },
            { "]d", desc = "Next Diagnostic" },

            -- Buffer Navigation
            { "<S-h>", desc = "Previous Buffer" },
            { "<S-l>", desc = "Next Buffer" },
            { "[b", desc = "Previous Buffer" },
            { "]b", desc = "Next Buffer" },

            -- Window Navigation (Ctrl+hjkl)
            { "<C-h>", desc = "Left Window" },
            { "<C-j>", desc = "Below Window" },
            { "<C-l>", desc = "Right Window" },

            -- Line Movement (Alt+jk)
            { "<A-j>", desc = "Move Line Down", mode = { "n", "i", "v" } },
            { "<A-k>", desc = "Move Line Up", mode = { "n", "i", "v" } },

            -- Visual Mode Indenting
            { "<", desc = "Indent Left", mode = "v" },
            { ">", desc = "Indent Right", mode = "v" },

            -- CodeCompanion Inline Actions
            { "ga", desc = "Accept AI Change", mode = "n" },
            { "gr", desc = "Reject AI Change", mode = "n" },
        })

        -- ========================================================================
        -- CUSTOM COMMANDS & ASSEMBLY UTILITIES
        -- ========================================================================
        -- Note: These are ex commands, not keymaps. Do NOT register ":" as a
        -- which-key group — it hijacks the command-line key.

        -- ========================================================================
        -- TELESCOPE FILE BROWSER
        -- ========================================================================
        wk.add({
            { "<space>fb", ":Telescope file_browser<CR>", desc = "File Browser", icon = "📁" },
        })

    end,
}

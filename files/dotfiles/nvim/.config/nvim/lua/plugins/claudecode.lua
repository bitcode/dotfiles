return {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    lazy = false,
    opts = {
        auto_start = true,
        log_level = "info",
        track_selection = true,
        focus_after_send = false,
        terminal = {
            split_side = "right",
            split_width_percentage = 0.35,
            provider = "snacks",
            auto_close = true,
            snacks_win_opts = {
                position = "right",
                keys = {
                    claude_hide = {
                        "<C-,>",
                        function(self) self:hide() end,
                        mode = "t",
                        desc = "Hide Claude",
                    },
                },
            },
        },
        diff_opts = {
            layout = "vertical",
            open_in_new_tab = false,
            keep_terminal_focus = false,
        },
    },
    keys = {
        { "<leader>cc", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
        { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
        { "<leader>cr", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume session" },
        { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue session" },
        { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
        { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add buffer to context" },
        { "<leader>cs", "<cmd>ClaudeCodeSend<cr>",        mode = "v", desc = "Send selection" },
        {
            "<leader>cs",
            "<cmd>ClaudeCodeTreeAdd<cr>",
            desc = "Add file from tree",
            ft = { "oil", "netrw" },
        },
        { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
        { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
}

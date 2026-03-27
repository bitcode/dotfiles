return {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    lazy = false,
    opts = {
        auto_start = true,
        log_level = "warn",
        track_selection = true,
        focus_after_send = false,
        terminal = {
            split_side = "right",
            split_width_percentage = 0.35,
            provider = "snacks",
            auto_close = true,
        },
        diff_opts = {
            layout = "vertical",
            open_in_new_tab = false,
            keep_terminal_focus = false,
        },
    },
    config = function(_, opts)
        require("claudecode").setup(opts)

        -- Terminal mode navigation: Ctrl+h/j/k/l to move between splits
        local tmap = function(lhs, rhs, desc)
            vim.keymap.set("t", lhs, rhs, { noremap = true, silent = true, desc = desc })
        end
        tmap("<C-h>", [[<C-\><C-n><C-w>h]], "Move to left split")
        tmap("<C-j>", [[<C-\><C-n><C-w>j]], "Move to below split")
        tmap("<C-k>", [[<C-\><C-n><C-w>k]], "Move to above split")
        tmap("<C-l>", [[<C-\><C-n><C-w>l]], "Move to right split")

        -- Clean exit: close Claude terminal before quitting Neovim
        vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
                -- Close any Claude terminal buffers so :q exits cleanly
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_valid(buf)
                        and vim.bo[buf].buftype == "terminal"
                        and vim.api.nvim_buf_get_name(buf):lower():find("claude") then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end
                end
                -- Also call the plugin's close method
                pcall(function()
                    require("claudecode.terminal").close()
                end)
            end,
        })
    end,
}

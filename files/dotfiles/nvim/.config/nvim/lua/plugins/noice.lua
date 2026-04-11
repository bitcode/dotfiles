return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        {
            "rcarriga/nvim-notify",
            opts = {
                background_colour = "#3B4252",
            },
        },
    },
    opts = {
        cmdline = {
            enabled = true,
            view = "cmdline_popup",
        },
        views = {
            cmdline_popup = {
                position = {
                    row = "50%",
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
                border = {
                    style = "rounded",
                    padding = { 0, 1 },
                },
                win_options = {
                    winhighlight = {
                        Normal      = "NoiceCmdlinePopup",
                        FloatBorder = "NoiceCmdlinePopupBorder",
                        FloatTitle  = "NoiceCmdlinePopupTitle",
                    },
                },
            },
            cmdline_popupmenu = {
                relative = "editor",
                position = {
                    row = "50%+3",
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = 10,
                },
                border = {
                    style = "rounded",
                    padding = { 0, 1 },
                },
                win_options = {
                    winhighlight = {
                        Normal      = "NoicePopupmenu",
                        FloatBorder = "NoicePopupmenuBorder",
                        CursorLine  = "NoicePopupmenuSelected",
                        PmenuMatch  = "NoicePopupmenuMatch",
                    },
                },
            },
        },
        messages = {
            enabled = true,
        },
        popupmenu = {
            enabled = true,
            backend = "nui",
        },
        lsp = {
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
            },
        },
        presets = {
            bottom_search = true,
            command_palette = true,
            long_message_to_split = true,
            lsp_doc_border = true,
        },
        routes = {
            {
                filter = { event = "msg_show", kind = "search_count" },
                opts = { skip = true },
            },
        },
    },
    keys = {
        { "<leader>sn", "", desc = "Noice" },
        { "<leader>snl", function() require("noice").cmd("last") end, desc = "Last Message" },
        { "<leader>snh", function() require("noice").cmd("history") end, desc = "History" },
        { "<leader>sna", function() require("noice").cmd("all") end, desc = "All Messages" },
        { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
        { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Telescope" },
    },
}

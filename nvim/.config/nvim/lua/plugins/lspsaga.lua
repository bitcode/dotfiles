return {
    'nvimdev/lspsaga.nvim',
    name = "lspsaga",
    priority = 1000,
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        -- Function to check if code actions are supported
        local function has_code_action_support()
            local active_clients = vim.lsp.get_active_clients()
            for _, client in ipairs(active_clients) do
                if client.server_capabilities.codeActionProvider then
                    return true
                end
            end
            return false
        end

        -- Create the base configuration
        local saga_config = {
            symbol_in_winbar = {
                enable = true,
                separator = ' › ',
                show_file = true,
                color_mode = true
            },
            diagnostic = {
                show_code_action = has_code_action_support(),
                jump_num_shortcut = true,
                max_width = 0.8,
                max_height = 0.6,
                border_follow = true,
                diagnostic_only_current = false
            },
            finder = {
                max_height = 0.6,
                max_width = 0.8,
                default = 'ref+imp',
                methods = {
                    tyd = 'textDocument/typeDefinition'
                }
            },
            hover = {
                max_width = 0.8,
                max_height = 0.8,
                open_link = 'gx',
            },
            rename = {
                in_select = true,
                auto_save = false
            }
        }

        -- Only add code_action configuration if it's supported
        if has_code_action_support() then
            saga_config.code_action = {
                num_shortcut = true,
                show_server_name = true,
                extend_gitsigns = true,
                keys = {
                    quit = 'q',
                    exec = '<CR>',
                }
            }
        end

        -- Setup lspsaga with the conditional configuration
        require('lspsaga').setup(saga_config)

        -- Conditional keymaps
        if has_code_action_support() then
            vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true })
            vim.keymap.set("v", "<leader>ca", "<cmd><C-U>Lspsaga range_code_action<CR>", { silent = true })
        end

        -- Add an autocommand to update the configuration when LSP attaches
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client.server_capabilities.codeActionProvider then
                    -- Update the configuration if needed
                    saga_config.diagnostic.show_code_action = true
                    if not saga_config.code_action then
                        saga_config.code_action = {
                            num_shortcut = true,
                            show_server_name = true,
                            extend_gitsigns = true,
                            keys = {
                                quit = 'q',
                                exec = '<CR>',
                            }
                        }
                        require('lspsaga').setup(saga_config)
                    end
                end
            end,
        })
    end,
}

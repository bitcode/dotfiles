-- nvim/lua/plugins/codecompanion.lua
return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim",
        'echasnovski/mini.nvim',
    },
    opts = {
        log_level = "DEBUG", -- or "INFO", "WARN", "ERROR"
        strategies = {
            chat = {
                adapter = "anthropic", -- Default chat adapter, will use anthropic unless a specific prompt uses another one.
                keymaps = {},
            },
            variables = {
                ["my_var"] = {
                    callback = function()
                        return "Your custom content here."
                    end,
                    description = "Explain what my_var does",
                    opts = {
                        contains_code = false,
                    },
                },
            },
            slash_commands = {
                ["file"] = {
                    callback = "strategies.chat.slash_commands.file",
                    description = "Select a file using Telescope",
                    opts = {
                        provider = "telescope", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
                        contains_code = true,
                    },
                },
                ["mycmd"] = {
                    description = "Describe what mycmd inserts",
                    callback = function()
                        return "Custom context or data"
                    end,
                    opts = {
                        contains_code = true,
                    },
                },
            },
            agents = {
                ["my_agent"] = {
                    description = "A custom agent combining tools",
                    system_prompt = "Describe what the agent should do",
                    tools = {
                        "cmd_runner",
                        "editor",
                        -- Add your own tools or reuse existing ones
                    },
                },
            },
            tools = {
                ["my_tool"] = {
                    description = "Run a custom task",
                    callback = function(command)
                        -- Perform the custom task here
                        return "Tool result"
                    end,
                },
            },
        },
        inline = {
            adapter = "openai", --default inline adapter
            keymaps = {
                accept_change = {
                    modes = { n = "ga" },
                    description = "Accept the suggested change",
                },
                reject_change = {
                    modes = { n = "gr" },
                    description = "Reject the suggested change",
                },
            },
        }
    },
    adapters = {
        anthropic = {
            api_key = os.getenv("ANTHROPIC_API_KEY"),
            model = "claude-3-opus-20240229",
        },
        openai = {
            api_key = os.getenv("OPENAI_API_KEY"),
            model = "gpt-4-turbo-preview",
        },
        deepseek = {
            api_key = os.getenv("DEEPSEEK_API_KEY"),
            model = "deepseek-chat",
        },
        gemini = {
            api_key = os.getenv("GOOGLE_API_KEY"),
            model = "gemini-pro",
        },
        copilot = {
            -- No API Key needed, uses the copilot.lua plugin
            -- you may need to use :Copilot setup
        },
        ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
                name = "llama3", -- Give this adapter a different name to differentiate it from the default ollama adapter
                schema = {
                    model = {
                        default = "llama3:latest",
                    },
                    num_ctx = {
                        default = 16384,
                    },
                    num_predict = {
                        default = -1,
                    },
                },
            })
        end,
        openai_compatible = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                    url = "http[s]://open_compatible_ai_url", -- optional: default value is ollama url http://127.0.0.1:11434
                    api_key = "OpenAI_API_KEY",               -- optional: if your endpoint is authenticated
                    chat_url = "/v1/chat/completions",        -- optional: default value, override if different
                },
            })
        end,
        azure_openai = function()
            return require("codecompanion.adapters").extend("azure_openai", {
                env = {
                    api_key = "YOUR_AZURE_OPENAI_API_KEY",
                    endpoint = "YOUR_AZURE_OPENAI_ENDPOINT",
                },
                schema = {
                    model = {
                        default = "YOUR_DEPLOYMENT_NAME",
                    },
                },
            })
        end,
    },
    prompts = {
        -- Example of how to override a prompt to specify a different adapter per prompt
        ["lsp_error_explain"] = {
            adapter = "openai",
        },
    },
    display = {
        action_palette = {
            width = 95,
            height = 10,
            prompt = "Prompt ",                     -- Prompt used for interactive LLM calls
            provider = "telescope",                 -- default|telescope|mini_pick
            opts = {
                show_default_actions = true,        -- Show the default actions in the action palette?
                show_default_prompt_library = true, -- Show the default prompt library in the action palette?
            },
        },
        chat = {
            -- Options to customize the UI of the chat buffer
            window = {
                layout = "float", -- float|vertical|horizontal|buffer
                position = nil,   -- left|right|top|bottom (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)
                border = "single",
                height = 0.8,
                width = 0.8,
                relative = "editor",
                opts = {
                    breakindent = true,
                    cursorcolumn = false,
                    cursorline = false,
                    foldcolumn = "0",
                    linebreak = true,
                    list = false,
                    numberwidth = 1,
                    signcolumn = "no",
                    spell = false,
                    wrap = true,
                },
            },
            ---Customize how tokens are displayed
            ---@param tokens number
            ---@param adapter CodeCompanion.Adapter
            ---@return string
            token_count = function(tokens, adapter)
                return " (" .. tokens .. " tokens)"
            end,
            diff = {
                enabled = true,
                close_chat_at = 240,    -- Close an open chat buffer if the total columns of your display are less than...
                layout = "float",       -- vertical|horizontal split for default provider
                opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
                provider = "mini_diff", -- default|mini_diff
            },
            intro_message = "Welcome to CodeCompanion ✨! Press ? for options",
            show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
            separator = "─", -- The separator between the different messages in the chat buffer
            show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
            show_settings = false, -- Show LLM settings at the top of the chat buffer?
            show_token_count = true, -- Show the token count for each response?
            start_in_insert_mode = false, -- Open the chat buffer in insert mode?
        },
        inline = {
            layout = "vertical", -- vertical|horizontal|buffer
        },
    },
    opts = {
        log_level = "ERROR", -- TRACE|DEBUG|ERROR|INFO
        language = "English",
        send_code = true,
        system_prompt = function(opts)
            return "My new system prompt"
        end,
    },
    prompt_library = {
        ["Docusaurus"] = {
            strategy = "chat",
            description = "Write documentation for me",
            opts = {
                index = 11,
                is_slash_cmd = false,
                auto_submit = false,
                short_name = "docs",
            },
            references = {
                {
                    type = "file",
                    path = {
                        "doc/.vitepress/config.mjs",
                        "lua/codecompanion/config.lua",
                        "README.md",
                    },
                },
            },
            prompts = {
                {
                    role = "user",
                    content =
                    [[I'm rewriting the documentation for my plugin CodeCompanion.nvim, as I'm moving to a vitepress website. Can you help me rewrite it?

                  I'm sharing my vitepress config file so you have the context of how the documentation website is structured in the `sidebar` section of that file.

                  I'm also sharing my `config.lua` file which I'm mapping to the `configuration` section of the sidebar.
                ]],
                },
            },
        },
        ["Boilerplate HTML"] = {
            strategy = "inline",
            description = "Generate some boilerplate HTML",
            opts = {
                pre_hook = function()
                    local bufnr = vim.api.nvim_create_buf(true, false)
                    vim.api.nvim_buf_set_option(bufnr, "filetype", "html")
                    vim.api.nvim_set_current_buf(bufnr)
                    return bufnr
                end,
                mapping = "<leader>ch"
            },
            prompts = {
                {
                    role = "system",
                    content = "You are an expert HTML programmer",
                },
                {
                    role = "user",
                    content =
                    "Please generate some HTML boilerplate for me. Return the code only and no markdown codeblocks",
                },
            },
        },
        ["Code Expert"] = {
            strategy = "chat",
            description = "Get some special advice from an LLM",
            opts = {
                mapping = "<leader>ce",
                modes = { "v" },
                short_name = "expert",
                auto_submit = true,
                stop_context_insertion = true,
                user_prompt = true,
            },
            prompts = {
                {
                    role = "system",
                    content = function(context)
                        return "I want you to act as a senior "
                            .. context.filetype
                            .. " developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples."
                    end,
                },
                {
                    role = "user",
                    content = function(context)
                        local text = require("codecompanion.helpers.actions").get_code(context.start_line,
                            context.end_line)

                        return "I have the following code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
                    end,
                    opts = {
                        contains_code = true,
                    }
                },
            },
        },
        ["Test References"] = {
            strategy = "chat",
            description = "Add some references",
            opts = {
                index = 11,
                is_default = true,
                is_slash_cmd = false,
                short_name = "ref",
                auto_submit = false,
            },
            -- These will appear at the top of the chat buffer
            references = {
                {
                    type = "file",
                    path = { -- This can be a string or a table of values
                        "lua/codecompanion/health.lua",
                        "lua/codecompanion/http.lua",
                    },
                },
                {
                    type = "file",
                    path = "lua/codecompanion/schema.lua",
                },
                {
                    type = "symbols",
                    path = "lua/codecompanion/strategies/chat/init.lua",
                },
                {
                    type = "url", -- This URL will even be cached for you!
                    url =
                    "https://raw.githubusercontent.com/olimorris/codecompanion.nvim/refs/heads/main/lua/codecompanion/commands.lua",
                },
            },
            prompts = {
                {
                    role = "user",
                    content = "I'll think of something clever to put here...",
                    opts = {
                        contains_code = true,
                    },
                },
            },
        },
        ["Code workflow"] = {
            strategy = "workflow",
            description = "Use a workflow to guide an LLM in writing code",
            opts = {
                index = 4,
                is_default = true,
                short_name = "workflow",
            },
            prompts = {
                {
                    -- We can group prompts together to make a workflow
                    -- This is the first prompt in the workflow
                    {
                        role = "system",
                        content = function(context)
                            return string.format(
                                "You carefully provide accurate, factual, thoughtful, nuanced answers, and are brilliant at reasoning. If you think there might not be a correct answer, you say so. Always spend a few sentences explaining background context, assumptions, and step-by-step thinking BEFORE you try to answer a question. Don't be verbose in your answers, but do provide details and examples where it might help the explanation. You are an expert software engineer for the %s language",
                                context.filetype
                            )
                        end,
                        opts = {
                            visible = false,
                        },
                    },
                    {
                        role = "user",
                        content = "I want you to ",
                        opts = {
                            auto_submit = false,
                        },
                    },
                },
                -- This is the second group of prompts
                {
                    {
                        role = "user",
                        content =
                        "Great. Now let's consider your code. I'd like you to check it carefully for correctness, style, and efficiency, and give constructive criticism for how to improve it.",
                        opts = {
                            auto_submit = false,
                        },
                    },
                },
                -- This is the final group of prompts
                {
                    {
                        role = "user",
                        content =
                        "Thanks. Now let's revise the code based on the feedback, without additional explanations.",
                        opts = {
                            auto_submit = false,
                        },
                    },
                },
            },
        },
    },
}

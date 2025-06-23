return {
    'neovim/nvim-lspconfig', -- Repository for LSP configurations
    dependencies = {
        'hrsh7th/cmp-nvim-lsp', -- LSP completion source
    },
    config = function()
        local lspconfig = require('lspconfig')
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- Enhanced capabilities for LSP
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        capabilities.textDocument.completion.completionItem.preselectSupport = true
        capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
        capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
        capabilities.textDocument.completion.completionItem.deprecatedSupport = true
        capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
        capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
        capabilities.textDocument.completion.completionItem.resolveSupport = {
            properties = {
                'documentation',
                'detail',
                'additionalTextEdits',
            },
        }
        capabilities.textDocument.codeAction = {
            dynamicRegistration = false,
            codeActionLiteralSupport = {
                codeActionKind = {
                    valueSet = {
                        "",
                        "quickfix",
                        "refactor",
                        "refactor.extract",
                        "refactor.inline",
                        "refactor.rewrite",
                        "source",
                        "source.organizeImports",
                    },
                },
            },
        }

        -- Multi-architecture detection and configuration
        local function detect_architecture()
            local arch = vim.fn.system('uname -m'):gsub('\n', '')
            local os_name = vim.fn.system('uname -s'):gsub('\n', '')
            
            -- Architecture mapping
            local arch_map = {
                ['x86_64'] = 'x86_64',
                ['amd64'] = 'x86_64',
                ['i386'] = 'x86',
                ['i686'] = 'x86',
                ['arm64'] = 'arm64',
                ['aarch64'] = 'arm64',
                ['armv7l'] = 'arm',
                ['armv6l'] = 'arm',
                ['riscv64'] = 'riscv64',
            }
            
            return {
                arch = arch_map[arch] or 'unknown',
                os = os_name:lower(),
                raw_arch = arch
            }
        end

        -- Enhanced compiler detection
        local function detect_compilers()
            local compilers = {}
            
            -- Common assemblers and their architectures
            local assembler_configs = {
                ['as'] = { arch = 'auto', type = 'gas' },
                ['gas'] = { arch = 'auto', type = 'gas' },
                ['nasm'] = { arch = 'x86', type = 'nasm' },
                ['yasm'] = { arch = 'x86', type = 'yasm' },
                ['aarch64-linux-gnu-as'] = { arch = 'arm64', type = 'gas' },
                ['arm-linux-gnueabihf-as'] = { arch = 'arm', type = 'gas' },
                ['riscv64-linux-gnu-as'] = { arch = 'riscv64', type = 'gas' },
                ['clang'] = { arch = 'auto', type = 'clang' },
                ['gcc'] = { arch = 'auto', type = 'gcc' },
            }
            
            for assembler, config in pairs(assembler_configs) do
                if vim.fn.executable(assembler) == 1 then
                    compilers[assembler] = config
                end
            end
            
            return compilers
        end

        -- Project configuration helpers
        local function create_project_config(arch, assembler_type)
            local config_templates = {
                arm64 = {
                    instruction_set = "arm64",
                    assembler = "gas",
                    target = "aarch64-unknown-linux-gnu",
                    compile_flags = {
                        "-march=armv8-a",
                        "-mabi=lp64",
                        "-g",
                    }
                },
                arm = {
                    instruction_set = "arm",
                    assembler = "gas",
                    target = "arm-unknown-linux-gnueabihf",
                    compile_flags = {
                        "-march=armv7-a",
                        "-mfpu=neon",
                        "-g",
                    }
                },
                x86_64 = {
                    instruction_set = "x86_64",
                    assembler = assembler_type or "gas",
                    target = "x86_64-unknown-linux-gnu",
                    compile_flags = {
                        "-64",
                        "-g",
                    }
                },
                x86 = {
                    instruction_set = "x86",
                    assembler = assembler_type or "gas",
                    target = "i386-unknown-linux-gnu",
                    compile_flags = {
                        "-32",
                        "-g",
                    }
                },
                riscv64 = {
                    instruction_set = "riscv64",
                    assembler = "gas",
                    target = "riscv64-unknown-linux-gnu",
                    compile_flags = {
                        "-march=rv64gc",
                        "-mabi=lp64d",
                        "-g",
                    }
                }
            }
            
            return config_templates[arch] or config_templates.x86_64
        end

        -- Enhanced error handling and diagnostics
        local function setup_enhanced_diagnostics()
            vim.diagnostic.config({
                virtual_text = {
                    prefix = '●',
                    source = 'always',
                },
                float = {
                    source = 'always',
                    border = 'rounded',
                    header = 'Assembly Diagnostics',
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })
            
            -- Custom diagnostic signs for assembly
            local signs = {
                Error = "✘",
                Warn = "▲",
                Hint = "⚑",
                Info = "»"
            }
            
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end
        end

        -- Utility function to set up keymaps for assembly LSP
        local function setup_asm_keymaps(client, bufnr)
            local function buf_set_keymap(...)
                vim.api.nvim_buf_set_keymap(bufnr, ...)
            end
            local opts = { noremap = true, silent = true }

            -- Standard LSP keymaps
            buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
            buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
            buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
            buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
            buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
            buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
            buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

            -- ARM-specific documentation lookup
            buf_set_keymap('n', '<Leader>ad', '<Cmd>lua require("custom_arm_docs").open_arm_docs_for_word()<CR>',
                { noremap = true, silent = true, desc = "Open ARM AArch64 Docs for word under cursor" })

            -- Assembly-specific keymaps
            buf_set_keymap('n', '<Leader>ai', '<Cmd>lua vim.lsp.buf.hover()<CR>',
                { noremap = true, silent = true, desc = "Show instruction info" })
            buf_set_keymap('n', '<Leader>ar', '<Cmd>lua vim.lsp.buf.references()<CR>',
                { noremap = true, silent = true, desc = "Find label references" })
            
            -- Enhanced assembly-specific keymaps
            buf_set_keymap('n', '<Leader>ac', '<Cmd>lua require("asm_utils").create_project_config()<CR>',
                { noremap = true, silent = true, desc = "Create assembly project config" })
            buf_set_keymap('n', '<Leader>at', '<Cmd>lua require("asm_utils").toggle_architecture()<CR>',
                { noremap = true, silent = true, desc = "Toggle target architecture" })
            buf_set_keymap('n', '<Leader>as', '<Cmd>lua require("asm_utils").show_snippets()<CR>',
                { noremap = true, silent = true, desc = "Show assembly snippets" })
        end

        -- Enhanced on_attach function for assembly files
        local function on_attach(client, bufnr)
            setup_asm_keymaps(client, bufnr)

            -- Enable format on save if the LSP supports it
            if client.supports_method("textDocument/formatting") then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format({ bufnr = bufnr })
                    end,
                })
            end

            -- Assembly-specific autocommands
            vim.api.nvim_create_autocmd("CursorHold", {
                buffer = bufnr,
                callback = function()
                    -- Auto-show hover information for instructions after a delay
                    local opts = {
                        focusable = false,
                        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                        border = 'rounded',
                        source = 'always',
                        prefix = ' ',
                        scope = 'cursor',
                    }
                    vim.diagnostic.open_float(nil, opts)
                end,
            })
        end

        -- Initialize enhanced diagnostics
        setup_enhanced_diagnostics()
        
        -- Detect system architecture and available compilers
        local system_info = detect_architecture()
        local available_compilers = detect_compilers()
        
        -- Dynamic settings based on detected architecture
        local function get_dynamic_settings()
            local config = create_project_config(system_info.arch)
            
            return {
                instruction_set = config.instruction_set,
                assembler = config.assembler,
                target = config.target,
                diagnostics = true,
                default_diagnostics = true,
                version = "0.1",
                compile_flags = config.compile_flags,
            }
        end

        -- Setup lspconfig for asm_lsp with multi-architecture support
        lspconfig.asm_lsp.setup({
            cmd = { "asm-lsp" },
            filetypes = { "asm", "s", "S", "arm", "aarch64", "riscv" },
            -- Enhanced root directory pattern
            root_dir = lspconfig.util.root_pattern(
                ".asm-lsp.toml",
                "compile_flags.txt",
                ".git",
                "Makefile",
                "CMakeLists.txt"
            ),
            capabilities = capabilities,
            settings = get_dynamic_settings(),
            on_attach = function(client, bufnr)
                on_attach(client, bufnr)
                
                -- Initialize custom modules
                pcall(function()
                    require("custom_arm_docs").setup()
                end)
                
                pcall(function()
                    require("asm_utils").setup()
                end)
            end,
            flags = {
                debounce_text_changes = 150,
            },
            init_options = {
                -- Additional initialization options
                enable_hover = true,
                enable_completion = true,
                enable_diagnostics = true,
            },
        })

        -- Create assembly-specific autocommands
        vim.api.nvim_create_augroup("AssemblyLSP", { clear = true })
        
        -- Auto-detect architecture on assembly file open
        vim.api.nvim_create_autocmd("FileType", {
            group = "AssemblyLSP",
            pattern = { "asm", "s", "S", "arm", "aarch64", "riscv" },
            callback = function()
                -- Set assembly-specific options
                vim.opt_local.commentstring = "# %s"
                vim.opt_local.expandtab = false
                vim.opt_local.tabstop = 8
                vim.opt_local.shiftwidth = 8
                vim.opt_local.softtabstop = 8
                
                -- Enable syntax highlighting enhancements
                vim.cmd([[
                    syntax match asmLabel /^\s*[a-zA-Z_][a-zA-Z0-9_]*:/
                    syntax match asmDirective /\.[a-zA-Z][a-zA-Z0-9_]*/
                    syntax match asmRegister /\<[xwvqshbdXWVQSHBD][0-9]\+\>/
                    syntax match asmRegister /\<sp\|lr\|pc\|fp\>/
                    highlight link asmLabel Function
                    highlight link asmDirective PreProc
                    highlight link asmRegister Identifier
                ]])
            end,
        })

        -- Notify user about enhanced assembly LSP configuration
        vim.notify(string.format(
            "Enhanced Assembly LSP configured for %s (%s). Available compilers: %s. Use <Leader>ad for ARM docs.",
            system_info.arch,
            system_info.raw_arch,
            table.concat(vim.tbl_keys(available_compilers), ", ")
        ), vim.log.levels.INFO)
    end
}

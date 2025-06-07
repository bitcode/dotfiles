return {
    "nvimtools/none-ls.nvim",
    dependencies = { 'jose-elias-alvarez/null-ls.nvim' },
    priority = 1000,
    config = function()
        local null_ls = require("null-ls")
        local methods = null_ls.methods
        local sources = null_ls.builtins

        null_ls.setup({
            debug = false,
            sources = {
                -- Stylua for Lua formatting
                sources.formatting.stylua.with({
                    filetypes = { "lua" },
                    method = methods.FORMATTING,
                    config = {
                        -- any stylua config here
                    },
                }),

                -- GitSigns code actions, filtered to exclude "blame"
                sources.code_actions.gitsigns.with({
                    config = {
                        filter_actions = function(title)
                            return title:lower():match("blame") == nil
                        end,
                    },
                }),
                -- Generic Refactoring Code Actions (if desired)
                sources.code_actions.refactoring,

                -- Prettier for a *very specific* set of filetypes ONLY
                sources.formatting.prettier.with({
                    filetypes = {
                        "html",        -- HTML-like files (generally safe with no overlap)
                        "css",         -- CSS, but may have some overlap, monitor if issues
                        "scss",        -- SCSS, but may have some overlap, monitor if issues
                        "less",        -- Less, but may have some overlap, monitor if issues
                        "json",        -- JSON (if jsonls LSP does not provide good formatting)
                        "jsonc",       -- JSON with comments (if jsonls LSP does not provide good formatting)
                        "yaml",        -- YAML (if yamlls LSP does not provide good formatting)
                        "markdown",    -- Markdown files, monitor if conflicts
                        "markdown.mdx", -- Markdown.mdx, monitor if conflicts
                        "graphql",     -- GraphQL, monitor if conflicts
                        "handlebars",  -- Handlebars, monitor if conflicts
                        "svelte",      -- Svelte, monitor if conflicts
                        "astro",       -- Astro, monitor if conflicts
                        "htmlangular"  -- htmlangular, monitor if conflicts

                    },
                    method = methods.FORMATTING,
                }),
            },
        })
    end
}

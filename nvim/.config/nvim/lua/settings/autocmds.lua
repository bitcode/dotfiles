autocmd BufWritePre <buffer> lua_ls vim.lsp.buf.formatting_sync()

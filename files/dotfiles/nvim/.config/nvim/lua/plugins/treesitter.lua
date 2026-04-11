return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            -- On Windows, nvim-treesitter (main branch) shells out to the
            -- tree-sitter CLI, which in turn invokes cc-rs to compile each
            -- parser with cl.exe. cl.exe only works when the MSVC developer
            -- environment (PATH, INCLUDE, LIB) is loaded. Rather than require
            -- users to launch nvim from a Developer PowerShell, load vcvars64
            -- once on startup and inject the resulting vars into nvim's env so
            -- every child process inherits them.
            if vim.fn.has("win32") == 1 then
                local function find_vcvars()
                    local candidates = {
                        [[C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat]],
                        [[C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat]],
                        [[C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat]],
                        [[C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat]],
                        [[C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat]],
                    }
                    for _, path in ipairs(candidates) do
                        if vim.uv.fs_stat(path) then return path end
                    end
                    return nil
                end

                if vim.fn.executable("cl") == 0 then
                    local vcvars = find_vcvars()
                    if vcvars then
                        -- Windows cmd.exe argument quoting through vim.system is
                        -- lossy when the target path contains spaces. Write a
                        -- one-shot batch file that calls vcvars and dumps the
                        -- environment, then invoke that batch file by path.
                        local tmp = vim.fn.tempname() .. ".bat"
                        local f = io.open(tmp, "w")
                        if f then
                            f:write('@echo off\r\n')
                            f:write('call "' .. vcvars .. '" >NUL\r\n')
                            f:write('set\r\n')
                            f:close()
                            local result = vim.system({ "cmd.exe", "/c", tmp }, { text = true }):wait()
                            os.remove(tmp)
                            if result.code == 0 and result.stdout then
                                for line in result.stdout:gmatch("[^\r\n]+") do
                                    local k, v = line:match("^([^=]+)=(.*)$")
                                    if k and v then vim.uv.os_setenv(k, v) end
                                end
                            end
                        end
                    end
                end
            end

            -- Install parsers for commonly used languages
            local install = require("nvim-treesitter.install")
            local parsers = { "lua", "javascript", "asm", "c", "html", "go", "rust", "c_sharp" }
            local installed = require("nvim-treesitter.config").get_installed()
            local to_install = vim.tbl_filter(function(p)
                return not vim.tbl_contains(installed, p)
            end, parsers)
            if #to_install > 0 then
                install.install(to_install)
            end
        end,
    }
}

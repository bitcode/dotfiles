return {
    'voldikss/vim-floaterm',
    name = "floaterm",

    -- init runs BEFORE the plugin loads — required for g: variables
    init = function()
        -- ====================================================================
        -- NEOVIM TERMINAL SETTINGS
        -- Configure Neovim's built-in terminal emulator for maximum
        -- compatibility. These affect :terminal, floaterm, and any plugin
        -- that spawns terminal buffers.
        -- ====================================================================

        -- Enable 24-bit color in terminal buffers
        vim.o.termguicolors = true

        -- Sync screen updates to prevent tearing (nvim 0.10+)
        if vim.fn.exists('+termsync') == 1 then
            vim.o.termsync = true
        end

        -- Terminal color palette (Gruvbox-inspired, used by :terminal buffers)
        vim.g.terminal_color_0  = '#282828' -- black
        vim.g.terminal_color_1  = '#cc241d' -- red
        vim.g.terminal_color_2  = '#98971a' -- green
        vim.g.terminal_color_3  = '#d79921' -- yellow
        vim.g.terminal_color_4  = '#458588' -- blue
        vim.g.terminal_color_5  = '#b16286' -- magenta
        vim.g.terminal_color_6  = '#689d6a' -- cyan
        vim.g.terminal_color_7  = '#a89984' -- white
        vim.g.terminal_color_8  = '#928374' -- bright black
        vim.g.terminal_color_9  = '#fb4934' -- bright red
        vim.g.terminal_color_10 = '#b8bb26' -- bright green
        vim.g.terminal_color_11 = '#fabd2f' -- bright yellow
        vim.g.terminal_color_12 = '#83a598' -- bright blue
        vim.g.terminal_color_13 = '#d3869b' -- bright magenta
        vim.g.terminal_color_14 = '#8ec07c' -- bright cyan
        vim.g.terminal_color_15 = '#ebdbb2' -- bright white

        -- Floaterm shell: use bare 'pwsh' to avoid spaces-in-path issues
        if vim.fn.has('win32') == 1 then
            vim.g.floaterm_shell = 'pwsh -NoLogo -ExecutionPolicy RemoteSigned'
        end

        -- Window appearance
        vim.g.floaterm_width = 0.9
        vim.g.floaterm_height = 0.85
        vim.g.floaterm_wintype = 'float'
        vim.g.floaterm_position = 'center'
        vim.g.floaterm_borderchars = '─│─│╭╮╯╰'
        vim.g.floaterm_title = ' Terminal ($1/$2) '
        vim.g.floaterm_titleposition = 'center'

        -- Behavior
        vim.g.floaterm_autoclose = 1    -- close on clean exit, keep on error
        vim.g.floaterm_autohide = 1     -- hide previous when opening at same position
        vim.g.floaterm_autoinsert = true -- drop into insert/terminal mode immediately
        vim.g.floaterm_opener = 'edit'  -- open files from terminal in current window

        -- Git integration — use parent nvim as $GIT_EDITOR
        vim.g.floaterm_giteditor = true
    end,

    config = function()
        -- ====================================================================
        -- TERMINAL BUFFER AUTOCMDS
        -- Configure every terminal buffer for optimal experience
        -- ====================================================================

        -- TermOpen: runs when any terminal buffer is created
        vim.api.nvim_create_autocmd('TermOpen', {
            pattern = '*',
            callback = function()
                local buf = vim.api.nvim_get_current_buf()

                -- Clean terminal UI — no line numbers, sign column, or fold column
                vim.opt_local.number = false
                vim.opt_local.relativenumber = false
                vim.opt_local.signcolumn = 'no'
                vim.opt_local.foldcolumn = '0'

                -- Large scrollback for long-running sessions
                vim.opt_local.scrollback = 50000

                -- Don't list terminal buffers in :ls by default
                vim.bo[buf].buflisted = false

                -- Auto-enter insert mode when switching to a terminal buffer
                vim.cmd('startinsert')
            end,
        })

        -- Re-enter insert mode when focusing back into a terminal buffer
        vim.api.nvim_create_autocmd('BufEnter', {
            pattern = 'term://*',
            callback = function()
                if vim.bo.buftype == 'terminal' then
                    vim.cmd('startinsert')
                end
            end,
        })

        -- Track terminal CWD via OSC 7 (shell integration)
        vim.api.nvim_create_autocmd('TermRequest', {
            callback = function(ev)
                local seq = (ev.data or {}).sequence or ''
                -- OSC 7: file://hostname/path — update buffer-local cwd
                local path = seq:match('\027%]7;file://[^/]*(/.-)\027\\')
                if path then
                    -- Decode percent-encoded characters
                    path = path:gsub('%%(%x%x)', function(hex)
                        return string.char(tonumber(hex, 16))
                    end)
                    -- On Windows, convert /C:/path to C:/path
                    if vim.fn.has('win32') == 1 then
                        path = path:gsub('^/', '')
                    end
                    if vim.fn.isdirectory(path) == 1 then
                        vim.cmd.lcd(path)
                    end
                end
            end,
        })

        -- Responsive resize
        vim.api.nvim_create_autocmd('VimResized', {
            pattern = '*',
            callback = function()
                if vim.fn.exists(':FloatermUpdate') == 2 then
                    vim.cmd('FloatermUpdate --height=0.85 --width=0.9')
                end
            end,
        })

        -- Gruvforest-aware highlights
        local function set_floaterm_hl()
            -- Dark background for terminal, accent border
            vim.api.nvim_set_hl(0, 'Floaterm', { bg = '#2D353B', fg = '#D4BE98' })
            vim.api.nvim_set_hl(0, 'FloatermBorder', { bg = '#2D353B', fg = '#A9B665' })
        end
        vim.api.nvim_create_autocmd('ColorScheme', { pattern = '*', callback = set_floaterm_hl })
        set_floaterm_hl()

        -- Terminal-mode keymaps (escape and navigate while INSIDE the terminal)
        -- <C-\><C-n> exits terminal mode first, then runs the command
        vim.keymap.set('t', '<C-\\><C-]>', '<C-\\><C-n>:FloatermToggle<CR>', { silent = true, desc = 'Toggle floaterm' })
        vim.keymap.set('t', '<C-\\><C-n>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
        vim.keymap.set('t', '<C-\\>n', '<C-\\><C-n>:FloatermNext<CR>', { silent = true, desc = 'Next floaterm' })
        vim.keymap.set('t', '<C-\\>p', '<C-\\><C-n>:FloatermPrev<CR>', { silent = true, desc = 'Prev floaterm' })
        vim.keymap.set('t', '<C-\\>q', '<C-\\><C-n>:FloatermKill<CR>', { silent = true, desc = 'Kill floaterm' })
        vim.keymap.set('t', '<C-\\>c', '<C-\\><C-n>:FloatermNew<CR>', { silent = true, desc = 'New floaterm' })

        -- F-key shortcuts that work in both normal and terminal mode
        vim.keymap.set('n', '<F7>', ':FloatermNew<CR>', { silent = true, desc = 'New floaterm' })
        vim.keymap.set('t', '<F7>', '<C-\\><C-n>:FloatermNew<CR>', { silent = true, desc = 'New floaterm' })
        vim.keymap.set('n', '<F8>', ':FloatermToggle<CR>', { silent = true, desc = 'Toggle floaterm' })
        vim.keymap.set('t', '<F8>', '<C-\\><C-n>:FloatermToggle<CR>', { silent = true, desc = 'Toggle floaterm' })

        -- Platform-aware compile & run command
        local function compile_and_run_cmd()
            local file = vim.fn.expand('%')
            local ext = vim.fn.expand('%:e')
            local base = vim.fn.expand('%:r')

            if vim.fn.has('win32') == 1 then
                if ext == 'c' then
                    return string.format('gcc "%s" -o "%s.exe" && "./%s.exe"; Read-Host "Press ENTER"', file, base, base)
                elseif ext == 'cpp' then
                    return string.format('g++ "%s" -o "%s.exe" && "./%s.exe"; Read-Host "Press ENTER"', file, base, base)
                elseif ext == 'py' then
                    return string.format('python "%s"; Read-Host "Press ENTER"', file)
                elseif ext == 'ps1' then
                    return string.format('& "./%s"; Read-Host "Press ENTER"', file)
                elseif ext == 'rs' then
                    return 'cargo run; Read-Host "Press ENTER"'
                elseif ext == 'go' then
                    return string.format('go run "%s"; Read-Host "Press ENTER"', file)
                else
                    return string.format('echo "No runner for .%s"', ext)
                end
            else
                if ext == 'c' then
                    return string.format("gcc '%s' -o '%s' && './%s'; echo 'Press ENTER'; read", file, base, base)
                elseif ext == 'cpp' then
                    return string.format("g++ '%s' -o '%s' && './%s'; echo 'Press ENTER'; read", file, base, base)
                elseif ext == 'py' then
                    return string.format("python3 '%s'; echo 'Press ENTER'; read", file)
                elseif ext == 'sh' then
                    return string.format("bash '%s'; echo 'Press ENTER'; read", file)
                elseif ext == 'rs' then
                    return "cargo run; echo 'Press ENTER'; read"
                elseif ext == 'go' then
                    return string.format("go run '%s'; echo 'Press ENTER'; read", file)
                else
                    return string.format("echo 'No runner for .%s'", ext)
                end
            end
        end

        -- User command for compile & run
        vim.api.nvim_create_user_command('FloatermRun', function()
            local cmd = compile_and_run_cmd()
            if vim.fn.has('win32') == 1 then
                vim.cmd('FloatermNew --autoclose=0 pwsh -NoProfile -Command ' .. cmd)
            else
                vim.cmd("FloatermNew --autoclose=0 bash -c " .. vim.fn.shellescape(cmd))
            end
        end, { desc = 'Compile and run current file in floaterm' })

        -- Named terminal launchers
        vim.api.nvim_create_user_command('FloatermLazygit', function()
            vim.cmd('FloatermNew --name=lazygit --title=lazygit --disposable lazygit')
        end, { desc = 'Open lazygit in floaterm' })

        vim.api.nvim_create_user_command('FloatermNode', function()
            vim.cmd('FloatermNew --name=node --title=node node')
        end, { desc = 'Open Node REPL in floaterm' })

        vim.api.nvim_create_user_command('FloatermPython', function()
            local py = vim.fn.has('win32') == 1 and 'python' or 'python3'
            vim.cmd('FloatermNew --name=python --title=python ' .. py)
        end, { desc = 'Open Python REPL in floaterm' })

        -- Send visual selection to floaterm
        vim.api.nvim_create_user_command('FloatermSendVisual', function()
            vim.cmd("'<,'>FloatermSend")
        end, { range = true, desc = 'Send visual selection to floaterm' })
    end,
}

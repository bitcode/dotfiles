return {
  "L3MON4D3/LuaSnip",
  version = "v2.3.0", -- Use the latest major version
--build = "make install_jsregexp", -- Install jsregexp if needed
  config = function()
    local ls = require("luasnip")

    -- Keybindings for expanding snippets
    vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
    vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump(1) end, {silent = true})
    vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})

    -- For changing choices in choiceNodes
    vim.keymap.set({"i", "s"}, "<C-E>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, {silent = true})

    -- Load VS Code snippets
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}


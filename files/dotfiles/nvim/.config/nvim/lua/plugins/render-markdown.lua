return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown", "markdown_inline", "quarto", "rmd", "Avante", "codecompanion" },
  opts = {
    enabled = true,
    max_file_size = 10.0,
    debounce = 100,
    render_modes = { "n", "c", "t" },
    anti_conceal = { enabled = true },

    latex = {
      enabled = true,
      render_modes = false,
      converter = "latex2text",
      highlight = "RenderMarkdownMath",
      top_pad = 0,
      bottom_pad = 0,
    },

    heading = {
      enabled = true,
      sign = true,
      position = "overlay",
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      signs = { "󰫎 " },
      width = "full",
      left_margin = 0,
      left_pad = 0,
      right_pad = 0,
      min_width = 0,
      border = false,
      border_virtual = false,
      border_prefix = false,
      above = "▄",
      below = "▀",
      backgrounds = {
        "RenderMarkdownH1Bg",
        "RenderMarkdownH2Bg",
        "RenderMarkdownH3Bg",
        "RenderMarkdownH4Bg",
        "RenderMarkdownH5Bg",
        "RenderMarkdownH6Bg",
      },
      foregrounds = {
        "RenderMarkdownH1",
        "RenderMarkdownH2",
        "RenderMarkdownH3",
        "RenderMarkdownH4",
        "RenderMarkdownH5",
        "RenderMarkdownH6",
      },
    },

    paragraph = {
      enabled = true,
      left_margin = 0,
      min_width = 0,
    },

    code = {
      enabled = true,
      sign = true,
      style = "full",
      position = "left",
      language_pad = 0,
      language_name = true,
      disable_background = { "diff" },
      width = "full",
      left_margin = 0,
      left_pad = 0,
      right_pad = 0,
      min_width = 0,
      border = "thin",
      above = "▄",
      below = "▀",
      highlight = "RenderMarkdownCode",
      highlight_inline = "RenderMarkdownCodeInline",
      highlight_language = nil,
      inline_pad = 0,
    },

    dash = {
      enabled = true,
      icon = "─",
      width = "full",
      left_margin = 0,
      highlight = "RenderMarkdownDash",
    },

    bullet = {
      enabled = true,
      icons = { "●", "○", "◆", "◇" },
      ordered_icons = {},
      left_pad = 0,
      right_pad = 0,
      highlight = "RenderMarkdownBullet",
    },

    checkbox = {
      enabled = true,
      position = "overlay",
      unchecked = {
        icon = "󰄱 ",
        highlight = "RenderMarkdownUnchecked",
        scope_highlight = nil,
      },
      checked = {
        icon = "󰱒 ",
        highlight = "RenderMarkdownChecked",
        scope_highlight = nil,
      },
      custom = {
        todo     = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo",     scope_highlight = nil },
        important = { raw = "[!]", rendered = "󰀦 ", highlight = "DiagnosticWarn",         scope_highlight = nil },
        question = { raw = "[?]", rendered = "󰘥 ", highlight = "DiagnosticInfo",          scope_highlight = nil },
        cancelled = { raw = "[~]", rendered = "󰜺 ", highlight = "RenderMarkdownCancelled", scope_highlight = nil },
        star     = { raw = "[*]", rendered = "󰓎 ", highlight = "DiagnosticHint",          scope_highlight = nil },
      },
    },

    quote = {
      enabled = true,
      icon = "▋",
      repeat_linebreak = false,
      highlight = "RenderMarkdownQuote",
    },

    pipe_table = {
      enabled = true,
      preset = "round",
      style = "full",
      cell = "padded",
      padding = 1,
      min_width = 0,
      border = {
        "╭", "┬", "╮",
        "├", "┼", "┤",
        "╰", "┴", "╯",
        "│", "─",
      },
      alignment_indicator = "━",
      head = "RenderMarkdownTableHead",
      row = "RenderMarkdownTableRow",
      filler = "RenderMarkdownTableFill",
    },

    callout = {
      note      = { raw = "[!NOTE]",      rendered = "󰋽 Note",      highlight = "RenderMarkdownInfo",    quote_icon = "▋" },
      tip       = { raw = "[!TIP]",       rendered = "󰌶 Tip",       highlight = "RenderMarkdownSuccess", quote_icon = "▋" },
      important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint",    quote_icon = "▋" },
      warning   = { raw = "[!WARNING]",   rendered = "󰀪 Warning",   highlight = "RenderMarkdownWarn",    quote_icon = "▋" },
      caution   = { raw = "[!CAUTION]",   rendered = "󰳦 Caution",   highlight = "RenderMarkdownError",   quote_icon = "▋" },
      abstract  = { raw = "[!ABSTRACT]",  rendered = "󰨸 Abstract",  highlight = "RenderMarkdownInfo",    quote_icon = "▋" },
      summary   = { raw = "[!SUMMARY]",   rendered = "󰨸 Summary",   highlight = "RenderMarkdownInfo",    quote_icon = "▋" },
      tldr      = { raw = "[!TLDR]",      rendered = "󰨸 TLDR",      highlight = "RenderMarkdownInfo",    quote_icon = "▋" },
      info      = { raw = "[!INFO]",      rendered = "󰋽 Info",      highlight = "RenderMarkdownInfo",    quote_icon = "▋" },
      todo      = { raw = "[!TODO]",      rendered = "󰗡 Todo",      highlight = "RenderMarkdownInfo",    quote_icon = "▋" },
      hint      = { raw = "[!HINT]",      rendered = "󰌶 Hint",      highlight = "RenderMarkdownSuccess", quote_icon = "▋" },
      success   = { raw = "[!SUCCESS]",   rendered = "󰄬 Success",   highlight = "RenderMarkdownSuccess", quote_icon = "▋" },
      check     = { raw = "[!CHECK]",     rendered = "󰄬 Check",     highlight = "RenderMarkdownSuccess", quote_icon = "▋" },
      done      = { raw = "[!DONE]",      rendered = "󰄬 Done",      highlight = "RenderMarkdownSuccess", quote_icon = "▋" },
      question  = { raw = "[!QUESTION]",  rendered = "󰘥 Question",  highlight = "RenderMarkdownWarn",    quote_icon = "▋" },
      help      = { raw = "[!HELP]",      rendered = "󰘥 Help",      highlight = "RenderMarkdownWarn",    quote_icon = "▋" },
      faq       = { raw = "[!FAQ]",       rendered = "󰘥 FAQ",       highlight = "RenderMarkdownWarn",    quote_icon = "▋" },
      attention = { raw = "[!ATTENTION]", rendered = "󰀪 Attention", highlight = "RenderMarkdownWarn",    quote_icon = "▋" },
      failure   = { raw = "[!FAILURE]",   rendered = "󰅖 Failure",   highlight = "RenderMarkdownError",   quote_icon = "▋" },
      fail      = { raw = "[!FAIL]",      rendered = "󰅖 Fail",      highlight = "RenderMarkdownError",   quote_icon = "▋" },
      missing   = { raw = "[!MISSING]",   rendered = "󰅖 Missing",   highlight = "RenderMarkdownError",   quote_icon = "▋" },
      danger    = { raw = "[!DANGER]",    rendered = "󱐌 Danger",    highlight = "RenderMarkdownError",   quote_icon = "▋" },
      error     = { raw = "[!ERROR]",     rendered = "󱐌 Error",     highlight = "RenderMarkdownError",   quote_icon = "▋" },
      bug       = { raw = "[!BUG]",       rendered = "󰨰 Bug",       highlight = "RenderMarkdownError",   quote_icon = "▋" },
      example   = { raw = "[!EXAMPLE]",   rendered = "󰉹 Example",   highlight = "RenderMarkdownHint",    quote_icon = "▋" },
      quote     = { raw = "[!QUOTE]",     rendered = "󱆨 Quote",     highlight = "RenderMarkdownQuote",   quote_icon = "▋" },
      cite      = { raw = "[!CITE]",      rendered = "󱆨 Cite",      highlight = "RenderMarkdownQuote",   quote_icon = "▋" },
    },

    link = {
      enabled = true,
      image = "󰥶 ",
      email = "󰀓 ",
      hyperlink = "󰌹 ",
      highlight = "RenderMarkdownLink",
      wiki = { icon = "󱗖 ", highlight = "RenderMarkdownWikiLink" },
      custom = {
        web    = { pattern = "^http[s]?://",       icon = "󰖟 ", highlight = "RenderMarkdownLink" },
        github = { pattern = "github%.com",        icon = "󰊤 ", highlight = "RenderMarkdownLink" },
        gitlab = { pattern = "gitlab%.com",        icon = "󰮠 ", highlight = "RenderMarkdownLink" },
        youtube = { pattern = "youtube%.com",      icon = "󰗃 ", highlight = "RenderMarkdownLink" },
        neovim = { pattern = "neovim%.io",         icon = " ",  highlight = "RenderMarkdownLink" },
        stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 ", highlight = "RenderMarkdownLink" },
        wikipedia = { pattern = "wikipedia%.org",  icon = "󰖬 ", highlight = "RenderMarkdownLink" },
      },
    },

    sign = {
      enabled = true,
      highlight = "RenderMarkdownSign",
    },

    inline_highlight = {
      enabled = true,
      highlight = "RenderMarkdownInlineHighlight",
    },

    indent = {
      enabled = false,
      per_level = 2,
      skip_level = 1,
      skip_heading = false,
    },

    html = {
      enabled = true,
      comment = {
        conceal = true,
        text = nil,
        highlight = "RenderMarkdownHtmlComment",
      },
    },

    win_options = {
      conceallevel = { default = vim.o.conceallevel, rendered = 3 },
      concealcursor = { default = vim.o.concealcursor, rendered = "" },
    },

    overrides = {
      filetype = {
        codecompanion = { render_modes = true },
      },
    },

    on = {
      attach = function() end,
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)

    local gruvbox = {
      bg0 = "#282828", bg1 = "#3c3836", bg2 = "#504945",
      fg  = "#ebdbb2",
      red = "#fb4934", green = "#b8bb26", yellow = "#fabd2f",
      blue = "#83a598", purple = "#d3869b", aqua = "#8ec07c", orange = "#fe8019",
    }
    local hl = vim.api.nvim_set_hl
    hl(0, "RenderMarkdownH1",   { fg = gruvbox.red,    bold = true })
    hl(0, "RenderMarkdownH2",   { fg = gruvbox.orange, bold = true })
    hl(0, "RenderMarkdownH3",   { fg = gruvbox.yellow, bold = true })
    hl(0, "RenderMarkdownH4",   { fg = gruvbox.green,  bold = true })
    hl(0, "RenderMarkdownH5",   { fg = gruvbox.aqua,   bold = true })
    hl(0, "RenderMarkdownH6",   { fg = gruvbox.blue,   bold = true })
    hl(0, "RenderMarkdownH1Bg", { bg = "#4a1e1e" })
    hl(0, "RenderMarkdownH2Bg", { bg = "#4a2e1a" })
    hl(0, "RenderMarkdownH3Bg", { bg = "#4a3e1a" })
    hl(0, "RenderMarkdownH4Bg", { bg = "#2e4a1e" })
    hl(0, "RenderMarkdownH5Bg", { bg = "#1e4a3e" })
    hl(0, "RenderMarkdownH6Bg", { bg = "#1e3a4a" })
    hl(0, "RenderMarkdownCode",       { bg = "#1d2021" })
    hl(0, "RenderMarkdownCodeInline", { bg = gruvbox.bg1, fg = gruvbox.aqua })
    hl(0, "RenderMarkdownMath",       { fg = gruvbox.purple, italic = true })
    hl(0, "RenderMarkdownQuote",      { fg = gruvbox.purple })
    hl(0, "RenderMarkdownBullet",     { fg = gruvbox.orange })
    hl(0, "RenderMarkdownDash",       { fg = gruvbox.bg2 })
    hl(0, "RenderMarkdownLink",       { fg = gruvbox.blue, underline = true })
    hl(0, "RenderMarkdownWikiLink",   { fg = gruvbox.aqua, underline = true })
    hl(0, "RenderMarkdownTableHead",  { fg = gruvbox.red })
    hl(0, "RenderMarkdownTableRow",   { fg = gruvbox.yellow })
    hl(0, "RenderMarkdownTableFill",  { fg = gruvbox.bg2 })
    hl(0, "RenderMarkdownInfo",    { fg = gruvbox.blue,   bold = true })
    hl(0, "RenderMarkdownSuccess", { fg = gruvbox.green,  bold = true })
    hl(0, "RenderMarkdownHint",    { fg = gruvbox.aqua,   bold = true })
    hl(0, "RenderMarkdownWarn",    { fg = gruvbox.yellow, bold = true })
    hl(0, "RenderMarkdownError",   { fg = gruvbox.red,    bold = true })
    hl(0, "RenderMarkdownUnchecked",  { fg = gruvbox.bg2 })
    hl(0, "RenderMarkdownChecked",    { fg = gruvbox.green })
    hl(0, "RenderMarkdownTodo",       { fg = gruvbox.yellow })
    hl(0, "RenderMarkdownCancelled",  { fg = gruvbox.bg2, strikethrough = true })
    hl(0, "RenderMarkdownSign",       { fg = gruvbox.bg2 })
    hl(0, "RenderMarkdownInlineHighlight", { fg = gruvbox.yellow, bg = gruvbox.bg1 })
    hl(0, "RenderMarkdownHtmlComment", { fg = gruvbox.bg2, italic = true })
  end,
}

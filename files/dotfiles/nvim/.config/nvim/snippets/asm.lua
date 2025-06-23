-- Assembly Language Snippets for Neovim
-- Supports multiple architectures with context-aware snippets

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- Helper function to detect architecture from file content or project config
local function get_arch_context()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 50, false)
  -- Check for architecture-specific patterns in the file
  for _, line in ipairs(lines) do
    if line:match("aarch64") or line:match("arm64") or line:match("x[0-9]+") then
      return "arm64"
    elseif line:match("x86_64") or line:match("%rax") or line:match("%rdi") then
      return "x86_64"
    elseif line:match("riscv") then
      return "riscv64"
    end
  end
  -- Check project configuration
  local cwd = vim.fn.getcwd()
  local config_file = cwd .. "/.asm-lsp.toml"
  if vim.fn.filereadable(config_file) == 1 then
    local content = vim.fn.readfile(config_file)
    for _, line in ipairs(content) do
      if line:match('architecture = "([^"]+)"') then
        return line:match('architecture = "([^"]+)"')
      end
    end
  end
  -- Default to system architecture
  local arch = vim.fn.system('uname -m'):gsub('\n', '')
  if arch:match("aarch64") or arch:match("arm64") then
    return "arm64"
  elseif arch:match("x86_64") then
    return "x86_64"
  else
    return "arm64" -- Default fallback
  end
end

-- ARM AArch64 Snippets
local arm64_snippets = {
  -- Function templates
  s("func", fmt([[
.global {}
.type {}, @function
{}:
    // Function prologue
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    {}

    // Function epilogue
    ldp     x29, x30, [sp], #16
    ret
.size {}, . - {}
]], {
    i(1, "function_name"),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
    i(2, "// Function body"),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
  })),
  -- System call template
  s("syscall", fmt([[
    // System call: {}
    mov     x8, #{}
    mov     x0, {}
    mov     x1, {}
    mov     x2, {}
    mov     x3, {}
    svc     #0
]], {
    i(1, "syscall_name"),
    i(2, "syscall_number"),
    i(3, "#arg1"),
    i(4, "#arg2"),
    i(5, "#arg3"),
    i(6, "#arg4"),
  })),
  -- Loop template
  s("loop", fmt([[
    mov     x{}, #{}           // counter
    mov     x{}, #{}           // limit
{}:
    {}

    add     x{}, x{}, #1
    cmp     x{}, x{}
    b.lt    {}
]], {
    i(1, "0"),
    i(2, "0"),
    i(3, "1"),
    i(4, "10"),
    i(5, "loop"),
    i(6, "// loop body"),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[3][1] end, { 3 }),
    f(function(args) return args[5][1] end, { 5 }),
  })),
  -- Conditional template
  s("if", fmt([[
    cmp     x{}, x{}
    b.{}    {}

    {}

{}:
    {}
]], {
    i(1, "0"),
    i(2, "1"),
    c(3, { t("eq"), t("ne"), t("lt"), t("le"), t("gt"), t("ge") }),
    i(4, "condition_true"),
    i(5, "// false case"),
    f(function(args) return args[4][1] end, { 4 }),
    i(6, "// true case"),
  })),
  -- Memory operations
  s("mem", fmt([[
    // Memory operations
    ldr     x{}, [x{}]         // load 64-bit
    ldr     w{}, [x{}]         // load 32-bit
    ldrb    w{}, [x{}]         // load byte
    ldrh    w{}, [x{}]         // load halfword

    str     x{}, [x{}]         // store 64-bit
    str     w{}, [x{}]         // store 32-bit
    strb    w{}, [x{}]         // store byte
    strh    w{}, [x{}]         // store halfword
]], {
    i(1, "0"), i(2, "1"),
    i(3, "0"), i(4, "1"),
    i(5, "0"), i(6, "1"),
    i(7, "0"), i(8, "1"),
    i(9, "0"), i(10, "1"),
    i(11, "0"), i(12, "1"),
    i(13, "0"), i(14, "1"),
    i(15, "0"), i(16, "1"),
  })),
  -- Stack operations
  s("stack", fmt([[
    // Stack operations
    stp     x{}, x{}, [sp, #-16]!  // push pair
    ldp     x{}, x{}, [sp], #16    // pop pair

    str     x{}, [sp, #-16]!       // push single
    ldr     x{}, [sp], #16         // pop single
]], {
    i(1, "0"), i(2, "1"),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[2][1] end, { 2 }),
    i(3, "0"),
    f(function(args) return args[3][1] end, { 3 }),
  })),
  -- NEON/SIMD operations
  s("neon", fmt([[
    // NEON SIMD operations
    ld1     {{v{}.16b}}, [x{}]     // load 128-bit vector
    st1     {{v{}.16b}}, [x{}]     // store 128-bit vector

    add     v{}.16b, v{}.16b, v{}.16b  // vector add
    mul     v{}.8h, v{}.8h, v{}.8h     // vector multiply
]], {
    i(1, "0"), i(2, "1"),
    f(function(args) return args[1][1] end, { 1 }), i(3, "2"),
    i(4, "0"), i(5, "1"), i(6, "2"),
    i(7, "0"), i(8, "1"), i(9, "2"),
  })),

  -- Exception handling
  s("exception", fmt([[
    // Exception handling
    .align 11
exception_vector_table:
    // Current EL with SP0
    .align 7
    b       sync_current_el_sp0
    .align 7
    b       irq_current_el_sp0
    .align 7
    b       fiq_current_el_sp0
    .align 7
    b       serror_current_el_sp0

sync_current_el_sp0:
    {}
    eret

irq_current_el_sp0:
    {}
    eret
]], {
    i(1, "// Synchronous exception handler"),
    i(2, "// IRQ handler"),
  })),
}

-- x86_64 Snippets
local x86_64_snippets = {
  -- Function template
  s("func", fmt([[
.global {}
.type {}, @function
{}:
    # Function prologue
    pushq   %rbp
    movq    %rsp, %rbp

    {}

    # Function epilogue
    movq    %rbp, %rsp
    popq    %rbp
    ret
.size {}, . - {}
]], {
    i(1, "function_name"),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
    i(2, "# Function body"),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- System call template
  s("syscall", fmt([[
    # System call: {}
    movq    ${}, %rax
    movq    ${}, %rdi
    movq    ${}, %rsi
    movq    ${}, %rdx
    movq    ${}, %r10
    syscall
]], {
    i(1, "syscall_name"),
    i(2, "syscall_number"),
    i(3, "arg1"),
    i(4, "arg2"),
    i(5, "arg3"),
    i(6, "arg4"),
  })),

  -- Loop template
  s("loop", fmt([[
    movq    ${}, %rcx          # counter
    movq    ${}, %rdx          # limit
{}:
    {}

    incq    %rcx
    cmpq    %rdx, %rcx
    jl      {}
]], {
    i(1, "0"),
    i(2, "10"),
    i(3, "loop"),
    i(4, "# loop body"),
    f(function(args) return args[3][1] end, { 3 }),
  })),
}

-- Architecture-specific snippet selection
local function get_snippets()
  local arch = get_arch_context()

  if arch == "arm64" then
    return arm64_snippets
  elseif arch == "x86_64" then
    return x86_64_snippets
  else
    -- Default to ARM64 snippets
    return arm64_snippets
  end
end

-- Common snippets (architecture-agnostic)
local common_snippets = {
  -- File header
  s("header", fmt([[
/*
 * {}
 *
 * Description: {}
 * Author: {}
 * Date: {}
 * Architecture: {}
 */

.section .data
    {}

.section .bss
    {}

.section .text
.global _start

_start:
    {}
]], {
    i(1, "filename.s"),
    i(2, "Assembly program description"),
    i(3, "Your Name"),
    f(function() return os.date("%Y-%m-%d") end),
    f(function() return get_arch_context() end),
    i(4, "// Data declarations"),
    i(5, "// Uninitialized data"),
    i(6, "// Program entry point"),
  })),
  -- Section templates
  s("section", fmt([[
.section .{}
    {}
]], {
    c(1, { t("text"), t("data"), t("bss"), t("rodata") }),
    i(2, "// Section content"),
  })),
  -- Label template
  s("label", fmt([[
{}:
    {}
]], {
    i(1, "label_name"),
    i(2, "// Code after label"),
  })),
  -- Comment block
  s("comment", fmt([[
/*
 * {}
 */
]], {
    i(1, "Comment description"),
  })),
  -- Directive templates
  s("directive", fmt([[
.{} {}
]], {
    c(1, {
      t("align"), t("ascii"), t("asciz"), t("byte"), t("word"),
      t("long"), t("quad"), t("space"), t("zero"), t("global"),
      t("extern"), t("type"), t("size")
    }),
    i(2, "value"),
  })),
}

-- Combine all snippets
local all_snippets = {}

-- Add common snippets
for _, snippet in ipairs(common_snippets) do
  table.insert(all_snippets, snippet)
end

-- Add architecture-specific snippets
local arch_snippets = get_snippets()
for _, snippet in ipairs(arch_snippets) do
  table.insert(all_snippets, snippet)
end

return all_snippets


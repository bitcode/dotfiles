# Assembly Development Environment for Neovim

This comprehensive assembly development environment provides enhanced support for ARM AArch64, x86_64, and other architectures with intelligent tooling, documentation integration, and project templates.

## Features

### 🏗️ Multi-Architecture Support
- **ARM AArch64**: Full support with comprehensive instruction documentation
- **x86_64**: Intel/AMD 64-bit assembly support
- **ARM 32-bit**: ARMv7 and earlier support
- **RISC-V**: RISC-V 64-bit support
- **Automatic Detection**: Detects system architecture and configures accordingly

### 📚 Documentation Integration
- **ARM Documentation**: Direct links to official ARM AArch64 instruction documentation
- **Instruction Lookup**: Press `<Leader>ad` on any ARM instruction for instant documentation
- **Register Information**: Comprehensive register documentation for all supported architectures
- **System Registers**: Complete coverage of ARM system registers

### 🛠️ Project Configuration
- **Automatic Setup**: Creates `.asm-lsp.toml` and `compile_flags.txt` for your architecture
- **Template System**: Pre-configured templates for different architectures
- **Cross-compilation**: Support for cross-compilation toolchains

### 📝 Code Snippets
- **Architecture-aware**: Snippets adapt to your target architecture
- **Function Templates**: Complete function prologue/epilogue patterns
- **System Calls**: Pre-configured system call templates
- **SIMD/NEON**: Advanced vector instruction templates for ARM

## Quick Start

### 1. Create a New Assembly Project

```vim
:AsmCreateConfig
```

This command will:
- Detect your system architecture
- Create `.asm-lsp.toml` configuration file
- Create `compile_flags.txt` for precise diagnostics
- Generate an example assembly file

### 2. Key Bindings

| Key Binding | Description |
|-------------|-------------|
| `<Leader>ad` | Open ARM documentation for word under cursor |
| `<Leader>ai` | Show instruction information (hover) |
| `<Leader>ar` | Find label references |
| `<Leader>ac` | Create assembly project configuration |
| `<Leader>at` | Toggle target architecture |
| `<Leader>as` | Show and insert assembly snippets |

### 3. Available Commands

| Command | Description |
|---------|-------------|
| `:ArmDocs [instruction]` | Open ARM documentation |
| `:ArmInstructions` | List all available ARM instructions |
| `:AsmCreateConfig [arch]` | Create project configuration (optionally specify architecture) |
| `:AsmToggleArch` | Switch target architecture |
| `:AsmSnippets` | Show available snippets |
| `:AsmAssemblers` | List available assemblers |
| `:AsmStatus` | Show comprehensive architecture and toolchain status |

## Architecture-Specific Features

### ARM AArch64

#### Supported Instructions (150+)
- **Arithmetic**: `add`, `sub`, `mul`, `div`, `madd`, `msub`
- **Logical**: `and`, `orr`, `eor`, `bic`, `orn`, `eon`
- **Memory**: `ldr`, `str`, `ldp`, `stp`, `ldur`, `stur`
- **Branch**: `b`, `bl`, `br`, `blr`, `ret`, `cbz`, `cbnz`
- **Conditional**: `csel`, `csinc`, `csinv`, `csneg`
- **SIMD/NEON**: `ld1`, `st1`, `fadd`, `fmul`, `fcmp`
- **System**: `mrs`, `msr`, `svc`, `hvc`, `smc`

#### Register Documentation
- **General Purpose**: X0-X30, SP, LR, PC with calling convention info
- **System Registers**: SPSR_EL1, ELR_EL1, MIDR_EL1, SCTLR_EL1, etc.
- **NEON Registers**: V0-V31 with lane access patterns

#### Code Snippets
```assembly
# Function template
func<TAB>
# Expands to complete function with prologue/epilogue

# System call template  
syscall<TAB>
# Expands to system call with proper register setup

# Loop template
loop<TAB>
# Expands to complete loop structure

# NEON operations
neon<TAB>
# Expands to SIMD vector operations
```

### x86_64

#### Supported Features
- **System V ABI**: Proper calling convention support
- **System Calls**: Linux syscall interface
- **Memory Models**: 64-bit addressing modes
- **SSE/AVX**: Vector instruction support

#### Code Snippets
```assembly
# Function template
func<TAB>
# Expands to function with proper stack frame

# System call template
syscall<TAB>
# Expands to Linux syscall with registers

# Loop template
loop<TAB>
# Expands to x86_64 loop structure
```

### ARM32 (ARMv7)

#### Supported Features
- **ARM Instruction Set**: Full ARMv7-A instruction support
- **Thumb Mode**: Thumb and Thumb-2 instruction sets
- **NEON/VFP**: Vector and floating-point operations
- **System Calls**: Linux ARM32 syscall interface

#### Code Snippets
```assembly
@ Function template
func<TAB>
@ Expands to ARM32 function with proper stack management

@ System call template
syscall<TAB>
@ Expands to ARM32 syscall with software interrupt

@ Loop template
loop<TAB>
@ Expands to ARM32 loop structure with conditional branches
```

### RISC-V

#### Supported Features
- **RV64GC**: Base integer + compressed + multiply/divide + atomic + float/double
- **System Calls**: Linux RISC-V syscall interface
- **ABI Compliance**: RISC-V calling convention support
- **Modular ISA**: Support for various RISC-V extensions

#### Code Snippets
```assembly
# Function template
func<TAB>
# Expands to RISC-V function with proper stack frame

# System call template
syscall<TAB>
# Expands to RISC-V ecall with proper register setup

# Loop template
loop<TAB>
# Expands to RISC-V loop with branch instructions
```

## Project Configuration Files

### .asm-lsp.toml (ARM AArch64 Example)

```toml
[asm-lsp]
version = "0.1"

[asm-lsp.instruction_set]
architecture = "arm64"
assembler = "gas"

[asm-lsp.compile]
target = "aarch64-unknown-linux-gnu"
flags = ["-march=armv8-a", "-mabi=lp64", "-g"]

[asm-lsp.diagnostics]
enabled = true
show_hints = true
show_warnings = true

[asm-lsp.completion]
enabled = true
include_registers = true
include_instructions = true
```

### compile_flags.txt (ARM AArch64 Example)

```
-march=armv8-a
-mabi=lp64
-g
-Wall
-Wextra
-target
aarch64-unknown-linux-gnu
```

### Multi-Architecture Examples

#### ARM32 Configuration (.asm-lsp.toml)
```toml
[asm-lsp]
version = "0.1"

[asm-lsp.instruction_set]
architecture = "arm"
assembler = "gas"

[asm-lsp.compile]
target = "arm-unknown-linux-gnueabihf"
flags = ["-march=armv7-a", "-mfpu=neon", "-mfloat-abi=hard", "-g"]

[asm-lsp.diagnostics]
enabled = true
show_hints = true
show_warnings = true

[asm-lsp.completion]
enabled = true
include_registers = true
include_instructions = true
```

#### x86_64 Configuration (.asm-lsp.toml)
```toml
[asm-lsp]
version = "0.1"

[asm-lsp.instruction_set]
architecture = "x86_64"
assembler = "gas"

[asm-lsp.compile]
target = "x86_64-unknown-linux-gnu"
flags = ["-64", "-g"]

[asm-lsp.diagnostics]
enabled = true
show_hints = true
show_warnings = true

[asm-lsp.completion]
enabled = true
include_registers = true
include_instructions = true
```

#### RISC-V Configuration (.asm-lsp.toml)
```toml
[asm-lsp]
version = "0.1"

[asm-lsp.instruction_set]
architecture = "riscv64"
assembler = "gas"

[asm-lsp.compile]
target = "riscv64-unknown-linux-gnu"
flags = ["-march=rv64gc", "-mabi=lp64d", "-g"]

[asm-lsp.diagnostics]
enabled = true
show_hints = true
show_warnings = true

[asm-lsp.completion]
enabled = true
include_registers = true
include_instructions = true
```

## Advanced Usage

### Cross-Compilation Setup

For cross-compilation, ensure you have the appropriate toolchain installed:

#### Ubuntu/Debian
```bash
# ARM AArch64 cross-compiler
sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# ARM 32-bit cross-compiler
sudo apt install gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf

# RISC-V cross-compiler
sudo apt install gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu

# Development tools and emulators
sudo apt install qemu-user gdb-multiarch
```

#### macOS (using Homebrew)
```bash
# ARM AArch64 cross-compiler
brew install aarch64-elf-gcc

# ARM 32-bit cross-compiler
brew install arm-none-eabi-gcc

# RISC-V cross-compiler
brew install riscv64-elf-gcc

# QEMU for emulation
brew install qemu
```

#### Arch Linux
```bash
# ARM AArch64 cross-compiler
sudo pacman -S aarch64-linux-gnu-gcc aarch64-linux-gnu-binutils

# ARM 32-bit cross-compiler
sudo pacman -S arm-linux-gnueabihf-gcc arm-linux-gnueabihf-binutils

# RISC-V cross-compiler
sudo pacman -S riscv64-linux-gnu-gcc riscv64-linux-gnu-binutils

# Development tools
sudo pacman -S qemu-user gdb
```

### Architecture-Specific Setup Examples

#### Creating an ARM64 Project
```vim
:AsmCreateConfig arm64
```

#### Creating an x86_64 Project
```vim
:AsmCreateConfig x86_64
```

#### Creating a RISC-V Project
```vim
:AsmCreateConfig riscv
```

#### Switching Between Architectures
```vim
:AsmToggleArch
```
This will show a menu with all available architectures and their template status.

### Custom Architecture Configuration

To add support for a custom architecture:

1. Edit `asm_utils.lua` and add your architecture to `config_templates`
2. Create corresponding snippets in `snippets/asm.lua`
3. Add documentation links if available

### Integration with Build Systems

#### Makefile Integration
```makefile
# Use the same flags as LSP
CFLAGS := $(shell cat compile_flags.txt | tr '\n' ' ')

%.o: %.s
	$(AS) $(CFLAGS) -c $< -o $@
```

#### CMake Integration
```cmake
# Read compile flags from LSP configuration
file(READ "${CMAKE_SOURCE_DIR}/compile_flags.txt" COMPILE_FLAGS)
string(REPLACE "\n" ";" COMPILE_FLAGS_LIST ${COMPILE_FLAGS})
add_compile_options(${COMPILE_FLAGS_LIST})
```

## Troubleshooting

### Quick Diagnosis
Use the comprehensive status command to check your environment:
```vim
:AsmStatus
```
This will show:
- System architecture information
- Template availability for all architectures
- Toolchain status for each architecture
- Available commands

### LSP Not Working
1. Ensure `asm-lsp` is installed: `cargo install asm-lsp`
2. Check if configuration files exist: `.asm-lsp.toml` and `compile_flags.txt`
3. Verify template availability: `:AsmStatus`
4. Restart LSP: `:LspRestart`

### Missing Templates
1. Check template status: `:AsmStatus`
2. Recreate configuration: `:AsmCreateConfig [architecture]`
3. Verify file permissions in `~/.config/nvim/templates/`

### Cross-Compilation Issues
1. Check available toolchains: `:AsmAssemblers`
2. Install missing cross-compilers (see Cross-Compilation Setup)
3. Verify toolchain status: `:AsmStatus`

### Documentation Links Not Opening
1. Verify internet connection
2. Check if your system has a default browser configured
3. Try manual command: `:ArmDocs add`

### Snippets Not Available
1. Ensure LuaSnip is installed and configured
2. Check if `snippets/asm.lua` is in your Neovim configuration
3. Reload snippets: `:source ~/.config/nvim/snippets/asm.lua`
4. Test snippet availability: `:AsmSnippets`

### Architecture Detection Issues
1. Check system architecture: `uname -m`
2. View detected architecture: `:AsmStatus`
3. Manually specify in `.asm-lsp.toml`
4. Use `:AsmToggleArch` to switch architectures

### Template Naming Issues
Templates follow the naming convention:
- `asm-lsp_[architecture].toml`
- `compile_flags_[architecture].txt`
- `Makefile.[architecture]`

Ensure consistent naming when adding custom templates.

## Contributing

To contribute to this assembly development environment:

1. **Add New Instructions**: Update `custom_arm_docs.lua` with new instruction documentation
2. **Create Snippets**: Add architecture-specific snippets to `snippets/asm.lua`
3. **Improve Templates**: Enhance configuration templates in `templates/`
4. **Documentation**: Update this guide with new features

## Resources

### Official Documentation
- [ARM Architecture Reference Manual](https://developer.arm.com/documentation/ddi0487/latest)
- [ARM AArch64 Instruction Set](https://developer.arm.com/documentation/ddi0596/latest)
- [Intel 64 and IA-32 Architectures Software Developer's Manual](https://software.intel.com/content/www/us/en/develop/articles/intel-sdm.html)
- [RISC-V Instruction Set Manual](https://riscv.org/technical/specifications/)

### Tools
- [asm-lsp](https://github.com/bergercookie/asm-lsp) - Assembly Language Server Protocol
- [GNU Assembler (GAS)](https://sourceware.org/binutils/docs/as/)
- [NASM](https://www.nasm.us/) - The Netwide Assembler

### Learning Resources
- [ARM Assembly Language Programming](https://azeria-labs.com/writing-arm-assembly-part-1/)
- [x86_64 Assembly Language Programming](https://cs.lmu.edu/~ray/notes/nasmtutorial/)
- [RISC-V Assembly Programming](https://github.com/riscv-non-isa/riscv-asm-manual)

---

*This assembly development environment is designed to provide a comprehensive, modern development experience for assembly language programming across multiple architectures.*
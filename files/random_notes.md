# Cross-Platform Development Environment Reference

## Software I want per platform:

All Platforms:
- [x] git
- [] compilers (see comprehensive list below)
    - [] gcc
    - [] g++
    - [] clang
    - [] rust
    - [] go
    - [] node ( nvm )
    - [] python
    - [] c
    - [] asm
    - [] clang
    - [] cmake
    - [] make
    - [] typescript
    - [] lua

---

# Comprehensive Assemblers and Compilers Reference

## 1. Low-Level Assemblers by Architecture

### x86/x86_64 (Intel/AMD)

#### Cross-Platform Assemblers
- **NASM (Netwide Assembler)**
  - Syntax: Intel syntax
  - Platforms: Windows, macOS, Linux
  - Installation:
    - macOS: `brew install nasm`
    - Windows: Download from nasm.us or `choco install nasm`
    - Linux: `apt install nasm` / `pacman -S nasm`
  - Object formats: ELF, COFF, Mach-O, PE
  - Features: Clear syntax, excellent documentation

- **YASM (Yet Another Assembler)**
  - Syntax: Intel and AT&T
  - Platforms: Windows, macOS, Linux
  - Installation:
    - macOS: `brew install yasm`
    - Windows: `choco install yasm`
    - Linux: `apt install yasm` / `pacman -S yasm`
  - Object formats: ELF, COFF, Mach-O, PE
  - Features: Complete NASM rewrite, multiple syntax support

- **FASM (Flat Assembler)**
  - Syntax: Intel syntax
  - Platforms: Windows, macOS, Linux
  - Installation: Download from flatassembler.net
  - Object formats: Various
  - Features: Self-assembling, written in assembly

#### Platform-Specific x86/x64 Assemblers

**Windows**
- **MASM (Microsoft Macro Assembler)**
  - Syntax: Intel syntax
  - Installation: Included with Visual Studio
  - Object formats: COFF, PE
  - Features: Official Microsoft assembler, macro support

**macOS**
- **GNU Assembler (gas)**
  - Syntax: AT&T (default), Intel (with .intel_syntax directive)
  - Installation: Included with Xcode Command Line Tools
  - Object formats: Mach-O
  - Features: Part of GNU binutils, integrated with GCC

**Linux**
- **GNU Assembler (gas)**
  - Syntax: AT&T (default), Intel (with .intel_syntax directive)
  - Installation: Usually pre-installed, or `apt install binutils`
  - Object formats: ELF
  - Features: Standard Linux assembler, part of binutils

### ARM/ARM64 (including Apple Silicon M1/M2/M3/M4)

#### Cross-Platform ARM Assemblers
- **GNU Assembler (gas)**
  - Platforms: All (part of GCC toolchain)
  - Installation:
    - Cross-compilation toolchains: `arm-linux-gnueabihf-gcc`
    - Native: Included with system GCC
  - Features: Supports ARMv7, ARMv8 (AArch64)

- **LLVM Assembler**
  - Platforms: All (part of LLVM/Clang)
  - Installation: Included with Clang
  - Features: Modern ARM support, Apple Silicon optimized

#### Platform-Specific ARM Assemblers

**Apple Silicon (M1/M2/M3/M4)**
- **Xcode Assembler**
  - Installation: Xcode Command Line Tools
  - Features: Optimized for Apple Silicon, AArch64 support

**Linux ARM**
- **Cross-compilation toolchains**
  - `gcc-arm-linux-gnueabihf` (32-bit ARM)
  - `gcc-aarch64-linux-gnu` (64-bit ARM)
  - Installation: `apt install gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu`

### RISC-V

#### RISC-V Assemblers
- **GNU RISC-V Toolchain**
  - Installation:
    - Ubuntu: `apt install gcc-riscv64-linux-gnu`
    - Build from source: riscv-gnu-toolchain
  - Features: Complete RISC-V support (RV32, RV64)

- **LLVM RISC-V Support**
  - Installation: Recent LLVM/Clang versions
  - Features: Growing RISC-V support in LLVM ecosystem

### Other Architectures

#### MIPS
- **GNU MIPS Toolchain**
  - Installation: `gcc-mips-linux-gnu`, `gcc-mipsel-linux-gnu`
  - Features: Big-endian and little-endian support

#### PowerPC
- **GNU PowerPC Toolchain**
  - Installation: `gcc-powerpc-linux-gnu`, `gcc-powerpc64-linux-gnu`
  - Features: 32-bit and 64-bit PowerPC support

#### Z80/8080 (Retro/Embedded)
- **z80asm**
- **SDCC (Small Device C Compiler)** - includes Z80 assembler

## 2. Platform-Specific Assemblers and Toolchains

### Windows Toolchains

#### Microsoft Toolchain
- **Visual Studio Build Tools**
  - Components: MSVC, MASM, Windows SDK
  - Installation: Visual Studio Installer
  - Features: Official Windows development environment

- **Windows SDK**
  - Installation: Visual Studio Installer or standalone
  - Features: Windows API headers, libraries, tools

#### Alternative Windows Toolchains
- **MinGW-w64**
  - Installation: MSYS2, standalone installers
  - Features: GCC toolchain for Windows, POSIX compatibility

- **Clang/LLVM for Windows**
  - Installation: LLVM releases, Visual Studio integration
  - Features: Modern compiler, cross-platform compatibility

### macOS Toolchains

#### Apple Toolchain
- **Xcode Command Line Tools**
  - Installation: `xcode-select --install`
  - Components: Clang, gas, ld, Apple SDKs
  - Features: Official Apple development tools

- **Xcode (Full IDE)**
  - Installation: Mac App Store
  - Features: Complete development environment, iOS/macOS SDKs

#### Alternative macOS Toolchains
- **Homebrew GCC**
  - Installation: `brew install gcc`
  - Features: Latest GCC versions, alternative to Clang

### Linux Toolchains

#### Distribution-Specific

**Ubuntu/Debian**
- **build-essential**
  - Installation: `apt install build-essential`
  - Components: GCC, make, libc6-dev

- **Development packages**
  - `apt install gcc g++ clang llvm`

**Arch Linux**
- **base-devel**
  - Installation: `pacman -S base-devel`
  - Components: GCC, make, binutils

**Red Hat/CentOS/Fedora**
- **Development Tools**
  - Installation: `dnf groupinstall "Development Tools"`

### Embedded Systems Toolchains

#### ARM Embedded
- **GNU Arm Embedded Toolchain**
  - Installation: Download from ARM developer site
  - Features: Cortex-M, Cortex-A support

- **Keil MDK-ARM**
  - Platform: Windows
  - Features: Commercial ARM development environment

#### AVR (Arduino)
- **AVR-GCC**
  - Installation: Part of Arduino IDE, or `apt install gcc-avr`
  - Features: Atmel AVR microcontroller support

#### ESP32/ESP8266
- **ESP-IDF**
  - Installation: Espressif IoT Development Framework
  - Features: Xtensa and RISC-V ESP chips

## 3. High-Level Compilers by Language

### C/C++ Compilers

#### Cross-Platform C/C++
- **GCC (GNU Compiler Collection)**
  - Platforms: Linux (native), macOS (Homebrew), Windows (MinGW)
  - Installation:
    - Linux: Pre-installed or `apt install gcc g++`
    - macOS: `brew install gcc`
    - Windows: MinGW, MSYS2, or WSL
  - Features: Mature, excellent optimization, wide platform support
  - Cross-compilation: Extensive cross-compilation support

- **Clang/LLVM**
  - Platforms: All major platforms
  - Installation:
    - macOS: Pre-installed with Xcode
    - Linux: `apt install clang` / `pacman -S clang`
    - Windows: LLVM releases, Visual Studio integration
  - Features: Fast compilation, excellent diagnostics, modular design
  - Cross-compilation: Good cross-compilation support

- **Intel C++ Compiler (ICC/ICX)**
  - Platforms: Linux, Windows, macOS
  - Installation: Intel oneAPI toolkit
  - Features: Intel-optimized, vectorization, parallel processing

#### Platform-Specific C/C++

**Windows**
- **Microsoft Visual C++ (MSVC)**
  - Installation: Visual Studio or Build Tools
  - Features: Windows-optimized, excellent debugging, IntelliSense

**macOS**
- **Apple Clang**
  - Installation: Xcode Command Line Tools
  - Features: Apple Silicon optimized, Objective-C/C++ support

### Systems Programming Languages

#### Rust
- **rustc (Rust Compiler)**
  - Platforms: All major platforms
  - Installation: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
  - Package Manager: Cargo
  - Cross-compilation: Excellent cross-compilation support
  - Features: Memory safety, zero-cost abstractions, WebAssembly support

#### Go
- **go compiler**
  - Platforms: All major platforms
  - Installation: Download from golang.org or package managers
  - Cross-compilation: Built-in cross-compilation (`GOOS`, `GOARCH`)
  - Features: Fast compilation, garbage collection, concurrency

#### Zig
- **zig compiler**
  - Platforms: All major platforms
  - Installation: Download from ziglang.org
  - Cross-compilation: Excellent cross-compilation, C interop
  - Features: No hidden control flow, compile-time code execution

#### D
- **DMD (Digital Mars D)**
  - Platforms: Windows, Linux, macOS
  - Installation: Download from dlang.org
  - Features: Systems programming with garbage collection option

- **LDC (LLVM D Compiler)**
  - Platforms: All major platforms
  - Installation: Package managers or dlang.org
  - Features: LLVM-based, better optimization

#### Nim
- **nim compiler**
  - Platforms: All major platforms
  - Installation: Package managers or nim-lang.org
  - Cross-compilation: Good cross-compilation support
  - Features: Python-like syntax, compiles to C/C++/JavaScript

#### Crystal
- **crystal compiler**
  - Platforms: Linux, macOS (limited Windows support)
  - Installation: Package managers or crystal-lang.org
  - Features: Ruby-like syntax, static typing, LLVM-based

### Managed/VM Languages

#### Java
- **OpenJDK**
  - Platforms: All major platforms
  - Installation: Package managers, adoptium.net, oracle.com
  - Cross-compilation: Write once, run anywhere (JVM)
  - Features: Mature ecosystem, enterprise support

- **GraalVM**
  - Platforms: All major platforms
  - Installation: Download from graalvm.org
  - Features: Native image compilation, polyglot support

#### C# / .NET
- **.NET SDK**
  - Platforms: All major platforms
  - Installation: dotnet.microsoft.com
  - Cross-compilation: Multi-platform targeting
  - Features: Modern language features, extensive libraries

#### Kotlin
- **Kotlin/JVM, Kotlin/Native**
  - Platforms: All major platforms
  - Installation: IntelliJ IDEA, command line tools
  - Cross-compilation: JVM, Native, JavaScript targets
  - Features: Java interop, null safety

### Functional Languages

#### Haskell
- **GHC (Glasgow Haskell Compiler)**
  - Platforms: All major platforms
  - Installation: Haskell Platform, Stack, Cabal
  - Features: Pure functional, lazy evaluation, strong type system

#### OCaml
- **ocamlopt (native compiler)**
  - Platforms: All major platforms
  - Installation: OPAM package manager
  - Features: Functional/imperative hybrid, strong type inference

#### F#
- **F# Compiler**
  - Platforms: All major platforms (via .NET)
  - Installation: .NET SDK
  - Features: Functional-first, .NET interop

### Scripting Languages

#### Python
- **CPython**
  - Platforms: All major platforms
  - Installation: python.org, package managers
  - Features: Interpreted, extensive libraries

- **PyPy**
  - Platforms: All major platforms
  - Installation: pypy.org
  - Features: JIT compilation, faster execution

#### JavaScript/TypeScript
- **Node.js (V8)**
  - Platforms: All major platforms
  - Installation: nodejs.org, nvm
  - Features: Server-side JavaScript, npm ecosystem

- **TypeScript Compiler (tsc)**
  - Platforms: All major platforms
  - Installation: `npm install -g typescript`
  - Features: Static typing for JavaScript

- **Deno**
  - Platforms: All major platforms
  - Installation: deno.land
  - Features: Secure runtime, TypeScript built-in

- **Bun**
  - Platforms: macOS, Linux (Windows in development)
  - Installation: bun.sh
  - Features: Fast runtime, bundler, package manager

#### Ruby
- **MRI (Matz's Ruby Interpreter)**
  - Platforms: All major platforms
  - Installation: ruby-lang.org, rbenv, rvm
  - Features: Dynamic, object-oriented

#### Lua
- **Lua Interpreter**
  - Platforms: All major platforms
  - Installation: lua.org, package managers
  - Features: Lightweight, embeddable

- **LuaJIT**
  - Platforms: All major platforms
  - Installation: luajit.org
  - Features: Just-in-time compilation

## 4. Toolchain Ecosystems

### LLVM/Clang Ecosystem

#### Core Components
- **LLVM Core**
  - Features: Modular compiler infrastructure, optimization passes
  - Languages: C, C++, Objective-C, Swift, Rust, Julia

- **Clang**
  - Features: C/C++/Objective-C front-end, excellent diagnostics
  - Tools: clang-format, clang-tidy, static analyzer

- **LLDB**
  - Features: Debugger, part of LLVM project
  - Platforms: All major platforms

#### LLVM-Based Languages
- **Swift** (Apple)
- **Rust** (uses LLVM backend)
- **Julia** (JIT compilation via LLVM)
- **Zig** (uses LLVM backend)
- **Crystal** (uses LLVM backend)

#### LLVM Tools
- **llc** - LLVM static compiler
- **lli** - LLVM interpreter and JIT compiler
- **llvm-as** - LLVM assembler
- **llvm-dis** - LLVM disassembler
- **opt** - LLVM optimizer

### GNU Toolchain

#### Core Components
- **GCC (GNU Compiler Collection)**
  - Languages: C, C++, Fortran, Ada, Go, Objective-C
  - Features: Mature optimization, extensive target support

- **GNU Binutils**
  - **as** - GNU Assembler
  - **ld** - GNU Linker
  - **ar** - Archive tool
  - **objdump** - Object file analyzer
  - **nm** - Symbol table viewer
  - **strip** - Symbol stripper

- **GDB**
  - Features: GNU Debugger, scriptable, remote debugging
  - Platforms: All major platforms

#### GNU Build System
- **Autotools**
  - **autoconf** - Configure script generator
  - **automake** - Makefile generator
  - **libtool** - Library building tool

- **Make**
  - **GNU Make** - Build automation tool
  - Features: Parallel builds, pattern rules

### Platform-Specific SDKs

#### Windows SDKs
- **Windows SDK**
  - Components: Headers, libraries, tools for Windows API
  - Installation: Visual Studio Installer

- **DirectX SDK**
  - Features: Graphics and multimedia APIs
  - Installation: Microsoft downloads

- **.NET Framework SDK**
  - Features: .NET development tools and libraries
  - Installation: Visual Studio or standalone

#### macOS/iOS SDKs
- **macOS SDK**
  - Location: `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/`
  - Features: macOS APIs, frameworks

- **iOS SDK**
  - Location: Xcode.app bundle
  - Features: iOS development, Simulator support

- **Apple Silicon Optimization**
  - Universal binaries (x86_64 + arm64)
  - Rosetta 2 compatibility

#### Linux Development
- **glibc** - GNU C Library
- **musl** - Alternative C library (Alpine Linux)
- **Kernel headers** - Linux kernel API headers

### Cross-Compilation Toolchains

#### Embedded Cross-Compilation
- **Buildroot** - Embedded Linux build system
- **Yocto Project** - Linux distribution builder
- **OpenWrt** - Router firmware framework

#### Mobile Cross-Compilation
- **Android NDK** - Native development for Android
- **iOS Toolchain** - Cross-compilation for iOS (macOS only)

#### WebAssembly (WASM)
- **Emscripten** - C/C++ to WebAssembly
- **wasm-pack** - Rust to WebAssembly
- **AssemblyScript** - TypeScript-like language for WASM

## 5. Build Systems and Package Managers

### Universal Build Systems
- **CMake**
  - Platforms: All major platforms
  - Installation: cmake.org, package managers
  - Features: Cross-platform, generator-based

- **Meson**
  - Platforms: All major platforms
  - Installation: Python pip, package managers
  - Features: Fast, user-friendly, Ninja backend

- **Bazel**
  - Platforms: All major platforms
  - Installation: bazel.build
  - Features: Scalable, reproducible builds

- **Buck2**
  - Platforms: All major platforms
  - Installation: GitHub releases
  - Features: Meta's build system, fast incremental builds

### Language-Specific Build Tools

#### C/C++
- **Make** - Traditional build tool
- **Ninja** - Fast build system
- **Conan** - C/C++ package manager
- **vcpkg** - Microsoft C++ package manager

#### Rust
- **Cargo** - Built-in build tool and package manager

#### Go
- **go build** - Built-in build tool
- **go mod** - Module system

#### JavaScript/TypeScript
- **npm** - Package manager and build scripts
- **Yarn** - Alternative package manager
- **pnpm** - Fast, disk space efficient package manager
- **Webpack** - Module bundler
- **Vite** - Fast build tool
- **esbuild** - Extremely fast bundler

#### Python
- **pip** - Package installer
- **Poetry** - Dependency management and packaging
- **setuptools** - Package building
- **wheel** - Binary package format

## 6. Installation and Setup Recommendations

### Development Environment Setup

#### Essential Tools for All Platforms
1. **Version Control**: Git
2. **Text Editor/IDE**: VS Code, Vim/Neovim, Emacs
3. **Terminal**: Modern terminal with shell integration
4. **Package Manager**: Platform-specific (brew, choco, apt, pacman)

#### Platform-Specific Setup

**macOS Development Setup**
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essential development tools
brew install git cmake ninja llvm gcc rust go node python3
brew install --cask visual-studio-code
```

**Windows Development Setup**
```powershell
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install development tools
choco install git cmake ninja llvm mingw rust golang nodejs python vscode

# Or install Visual Studio with C++ workload
choco install visualstudio2022community --package-parameters "--add Microsoft.VisualStudio.Workload.NativeDesktop"
```

**Linux Development Setup (Ubuntu/Debian)**
```bash
# Update package list
sudo apt update

# Install essential development tools
sudo apt install build-essential git cmake ninja-build clang llvm
sudo apt install curl wget

# Install language-specific tools
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  # Rust
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash  # Node.js via nvm
```

### Cross-Platform Development Considerations

#### Architecture Targeting
- **x86_64**: Most common desktop/server architecture
- **ARM64**: Apple Silicon, modern ARM servers, mobile devices
- **ARM32**: Embedded systems, older ARM devices
- **RISC-V**: Emerging open-source architecture

#### Operating System Targeting
- **Windows**: MSVC ABI vs GNU ABI considerations
- **macOS**: Universal binaries for Intel + Apple Silicon
- **Linux**: Distribution-specific packaging (deb, rpm, AppImage, Flatpak)
- **Mobile**: iOS (ARM64), Android (ARM64, x86_64)
- **Web**: WebAssembly for browser deployment

#### Best Practices
1. **Use cross-platform build systems** (CMake, Meson)
2. **Test on target platforms** early and often
3. **Consider containerization** (Docker) for consistent environments
4. **Use CI/CD** for automated cross-platform testing
5. **Document platform-specific requirements** clearly
6. **Choose appropriate abstraction levels** for your use case

---

## Quick Reference: Installation Commands by Platform

### Package Managers
- **macOS**: `brew install <package>`
- **Windows**: `choco install <package>` or `winget install <package>`
- **Ubuntu/Debian**: `apt install <package>`
- **Arch Linux**: `pacman -S <package>`
- **CentOS/RHEL/Fedora**: `dnf install <package>` or `yum install <package>`

### Language Installers
- **Rust**: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Node.js**: Use nvm, or download from nodejs.org
- **Go**: Download from golang.org or use package manager
- **Python**: Use pyenv, or download from python.org

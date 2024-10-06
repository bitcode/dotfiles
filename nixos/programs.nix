{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rustc
    nodejs_20
    vimPlugins.luasnip
    alacritty
    lua5_1
    lua51Packages.luarocks
    tree-sitter
    wget
    readline
    ripgrep
    bzip2
    clang
    clang-tools
    cmake
    feh
    fd
    fontconfig
    gcc
    git
    go
    gnumake
    google-chrome
    i3
    i3blocks
    libffi
    llvm
    nasm
    neovim
    nerdfonts
    nodejs
    openssh
    openssl
    picom
    pkg-config
    python3
    ranger
    readline
    rofi
    rustup
    sesh
    sqlite
    stow
    tmux
    typescript
    unzip
    xclip
    xsel
    xz
    zlib
    zsh
    synergy
  ];

  # Set Lua 5.1 as the default Lua interpreter
  environment.variables = {
    LUA_PATH = "${pkgs.lua5_1}/share/lua/5.1/?.lua;${pkgs.lua5_1}/share/lua/5.1/?/init.lua;${pkgs.lua5_1}/lib/lua/5.1/?.so";
    LUA_CPATH = "${pkgs.lua5_1}/lib/lua/5.1/?.so";
  };
}

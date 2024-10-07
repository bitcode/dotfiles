{ config, pkgs, unstablePkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Stable packages
    lsd
    zoxide
    nix
    rustc
    nodejs_20
    vimPlugins.luasnip

    # Unstable packages from unstablePkgs
    unstablePkgs.neovim

    # More stable packages
    alacritty
    lua5_1
    lua51Packages.luarocks
    tree-sitter
    wget
    readline
    ripgrep
    bzip2
    clang
    ranger
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
    nerdfonts
    nodejs
    openssh
    openssl
    picom
    pkg-config
    python3
    python311Packages.pip
    readline
    rofi
    rustup
    fzf
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
    zsh-fzf-history-search
    zsh-vi-mode
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
  ];

  # Set Lua 5.1 as the default Lua interpreter
  environment.variables = {
    LUA_PATH = "${pkgs.lua5_1}/share/lua/5.1/?.lua;${pkgs.lua5_1}/share/lua/5.1/?/init.lua;${pkgs.lua5_1}/lib/lua/5.1/?.so";
    LUA_CPATH = "${pkgs.lua5_1}/lib/lua/5.1/?.so";
  };
}

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    alacritty
    bzip2
    clang
    clang-tools
    cmake
    feh
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
}


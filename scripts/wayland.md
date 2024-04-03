#### Pacman Packages
```
dunst dkms mdp acpi linux-headers lazygit inxi interception-tools lsd interception-caps2esc cpupower pciutils jq noto-fonts-emoji inotify-tools ttf-jetbrains-mono-nerd openssh cmake unzip ninja tree tree-sitter curl zsh stow ranger okular highlight wget tmux imagemagick haskell-pandoc perl-image-exiftool mediainfo atool libarchive unrar poppler mupdf-tools catdoc brightnessctl wl-clipboard freetype2 fontconfig pkg-config make libxcb libxkbcommon python3 firefox meson build-essential ninja-build cmake-extras gettext gettext-base libfontconfig-dev libffi-dev libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev libxkbcommon-dev libpixman-1-dev libudev-dev libseat-dev seatd libxcb-dri3-dev libvulkan-dev libvulkan-volk-dev vulkan-validationlayers-dev libvkfft-dev libgulkan-dev libegl-dev libgles2 libegl1-mesa-dev glslang-tools libinput-bin libinput-dev libxcb-composite0-dev libavutil-dev libavcodec-dev libavformat-dev libxcb-ewmh2 libxcb-ewmh-dev libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev libxcb-xinput-dev xdg-desktop-portal-wlr swaync waybar hyprpicker-git hyprshot vscode-codicons-git 7-zip-full hwdata-dev libdevel hwdata net-tools libsystemd-dev
```

#### Alacrity Wayland
```
git clone https://github.com/alacritty/alacritty.git
cargo build --release --no-default-features --features=wayland
```

#### Rust Install
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### Set ZSH default
```
chsh -s $(which zsh)
```

#### Oh-My-Zsh
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

#### Install NVM Node version manager
```
https://github.com/nvm-sh/nvm#manual-install
nvim install --lts
nvm alias default node
```

#### NPM Global Packages
```
npm install -g neovim
```

#### Neovim from source
```
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

#### Install PIP
```
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
```

#### Global PIP Packages
```
pip install --user neovim pynvim gpustat nvidia-ml-py
```

#### Global Cargo Installs
```
cargo install ripgrep fd-find ask-ollama
```

#### Install zsh-autosuggestions

```
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

#### Install zsh-syntax-highlighting

```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

#### Tmux Plugin Manager TPM
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### Powerlevel10k
```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

#### zsh ls history plugin
```
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
```

#### zsh vi-mode
```
git clone https://github.com/jeffreytse/zsh-vi-mode \
  $ZSH_CUSTOM/plugins/zsh-vi-mode
```

#### Github CLI
`https://github.com/cli/cli/blob/trunk/docs/source.md`
```
git clone https://github.com/cli/cli.git
cd gh-cli

make install

gh auth login

gh extension install github/gh-copilot

gh explain "awk"

gh copilot suggest "insert question"
```

#### Nerdfonts
```
git clone https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts && ./install.sh
```

#### Nvidia Installation

Check driver version
`cat /proc/driver/nvidia/version`

Check available drivers
`sudo ubuntu-drivers list`,
`apt search nvidia-driver`,
`apt-cache search nvidia-driver`,
`apt-cache search 'nvidia-driver-' | grep '^nvidia-driver-[[:digit:]]*'`,
`apt-cache search 'nvidia-dkms-' | grep '^nvidia-dkms-[[:digit:]]*'`

Lets assume we want the 525 driver version
`sudo ubuntu-drivers install nvidia:525`

#### Hyprland Nvidia Wiki
`https://wiki.hyprland.org/Nvidia/`

#### Build Hyprland
```
git clone --recursive https://github.com/hyprwm/Hyprland
cd Hyprland
make all && sudo make install
```

### Nvidia Troubleshooting

lspci
`lspci -v | grep VGA`

`nvidia-smi`

`nvidia-settings`

The Nvidia graphics driver requires several kernel modules to be loaded, including nvidia, nvidia-modeset, and nvidia-drm. You can check if these modules are loaded using the following command:
`lsmod | grep nvidia`

If the modules are not loaded, you may need to manually load them or update the initramfs to ensure they are loaded at boot.

nvtop
`sudo add-apt-repository ppa:flexiondotorg/nvtop`
`sudo apt install nvtop`

Check which  graphic card you have

`lspci -k | grep -A 2 -E "(VGA|3D)"`

Check which Kernel Modules / Drivers are loaded into memory

`cat /proc/modules`

Grub boot options

`/etc/default/grub`

which nvidia drivers are installed 

`pacman -Q | grep nvidia`

Add nvidia modules

`sudo vi /etc/mkinitcpio.conf`

add to modules

`nvidia nvidia_modeset nvidia_uvm nvidia_drm`

rebuild mkinitcpio.conf

`sudo mkinitcpio -P`





































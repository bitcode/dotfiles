#!/bin/bash

# Time zone
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc

# Locale
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf

# Network configuration
echo "netopsbox" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 netopsbox.localdomain netopsbox" >> /etc/hosts

# Root password
echo root:password | chpasswd

# Install packages
pacman -S grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers nvidia nvidia-utils nvidia-settings xorg openssh openvpn rofi xorg-xinit base-devel cmake unzip ninja tree tree-sitter curl nodejs-lts-fermium zsh stow ranger okular highlight pygmentize python-pygments xdg-utils npm xsel python-pyx python-pip wget ripgrep fd lua luarocks go go-tools discord pipewire pipewire-pulse pipewire-alsa alsa-utils lib32-libpulse pyright

# GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Services
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer

# Package installation
sudo pacman -Syu
sudo pacman -S wget curl git tmux vim stow lynx nmap tcpdump fontconfig openssl python gcc go clang cmake pkg-config unzip caca-utils highlight atool w3m poppler mediainfo go gopls clang caca-utils highlight atool w3m poppler readline 
yay -S --noconfirm python3.10 python3.10-venv 

# Rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# set zsh by default
chsh -s $(which zsh)

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

# Install Node.js using nvm
nvm install --lts

# Set the default Node.js version
nvm alias default node

# Activate nvm
source ~/.bashrc

# Install npm packages
npm install -g prettier eslint bash-language-server neovim typescript typescript-language-server pyright rls clangd lua-language-server

# Neovim from source
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

# Neovim prerequisites
python3 -m pip install --user --upgrade pynvim
pip3 install neovim selenium python-dotenv pynvim openai jedi pyx pythonx virtualenv python-lsp-server

# Install nerdfonts
git clone https://github.com/ryanoasis/nerd-fonts.git

# Install Ripgrep and fd
cargo install ripgrep fd-find stylua

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Tmux Plugin Manager TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# vim plugin dependencies
rustup toolchain add nightly

# install lua / luarocks
sudo pacman -S lua luarocks

# ls deluxe
cargo install --git https://github.com/Peltoche/lsd.git --branch master

# Install Ranger dev icons
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons

echo "default_linemode devicons" >> ~/.config/ranger/rc.conf

# zsh ls history plugin
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

# zsh vi-mode
git clone https://github.com 

#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update system
pacman -Syu

# Time zone
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc

# Locale
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# Network configuration
echo "netopsbox" > /etc/hostname
{
    echo "127.0.0.1 localhost"
    echo "::1       localhost"
    echo "127.0.1.1 netopsbox.localdomain netopsbox"
} > /etc/hosts

# Root password
echo root:password | chpasswd

# Install essential packages
pacman -S --needed base linux linux-firmware grub networkmanager iwd dhcpcd openssh openvpn sudo

# Enable essential services
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable iwd
systemctl enable dhcpcd@.service

# Set up GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Install additional packages
pacman -S --needed dunst dkms mdp acpi github-cli acpid linux-headers fzf lazygit inxi interception-tools lsd \
interception-caps2esc cpupower pciutils jq noto-fonts-emoji inotify-tools ttf-jetbrains-mono-nerd cmake unzip \
ninja tree tree-sitter curl zsh stow ranger okular highlight wget tmux imagemagick haskell-pandoc perl-image-exiftool \
mediainfo atool libarchive unrar poppler mupdf-tools catdoc brightnessctl wl-clipboard cmake freetype2 fontconfig \
pkg-config make libxcb libxkbcommon firefox python-pynvim weston waybar wofi lua luarocks go go-tools lib32-libpulse \
lynx nmap tcpdump gcc clang caca-utils ripgrep

# Install PyEnv
curl https://pyenv.run | bash
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
pyenv install --list | grep " 3\.[678]"
pyenv install -v 3.x.x

# Alacritty setup
git clone https://github.com/alacritty/alacritty.git
cd alacritty
cargo build --release --no-default-features --features=wayland
sudo cp target/release/alacritty /usr/local/bin
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
cd ..

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Set zsh by default
chsh -s $(which zsh)

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"

# Install Node.js using nvm
nvm install --lts
nvm alias default node

# Install npm packages
npm install -g neovim typescript typescript-language-server

# Neovim from source
git clone https://github.com/neovim/neovim
cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
cd ..

# Neovim prerequisites
python3 -m pip install --user --upgrade pynvim
pyenv exec pip install neovim pynvim

# Install Ripgrep, fd, zoxide
cargo install ripgrep fd-find zoxide

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Tmux Plugin Manager TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# zsh ls history plugin
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

# zsh-fzf-history-search
git clone https://github.com/joshskidmore/zsh-fzf-history-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search

# zsh vi-mode
git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-vi-mode

# AUR YAY Package Manager
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..

# Install YAY packages
yay -S hyprpicker-git hyprshot vscode-codicons-git hyprland-git 7-zip-full

# Setup Caps2Escape
sudo pacman -S interception-tools interception-caps2esc
sudo tee /etc/interception/udevmon.yaml > /dev/null <<EOT
- JOB: intercept -g \$DEVNODE | caps2esc | uinput -d \$DEVNODE
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
EOT

sudo tee /etc/systemd/system/udevmon.service > /dev/null <<EOT
[Unit]
Description=udevmon
Wants=systemd-udevd.service
After=systemd-udevd.service

[Service]
ExecStart=/usr/bin/nice -n -20 /usr/bin/udevmon -c /etc/interception/udevmon.yaml
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl enable udevmon.service
sudo systemctl start udevmon.service

# Install Lua and Luarocks
sudo pacman -S lua luarocks

# Install Ranger dev icons
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons

# Install Nerd Fonts
git clone https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install.sh
cd ..

# Nvidia commands (adjust as needed)
lspci -k | grep -A 2 -E "(VGA|3D)"
cat /proc/modules
pacman -Q | grep nvidia
# Add the following to modules in /etc/mkinitcpio.conf: nvidia nvidia_modeset nvidia_uvm nvidia_drm
sudo mkinitcpio -P

# Fix keyring issues
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate

# WSL clipboard issue fix
# WSL: sudo ln -s /mnt/d/Neovim/bin/win32yank.exe /usr/bin/win32yank

# Run Hyprland inside VM
# MOZ_ENABLE_WAYLAND=1 QT_QPA_PLATFORM=wayland XDG_SESSION_TYPE=wayland exec dbus-run-session Hyprland

# End of script
echo "Script execution completed. Reboot the system to apply all changes."

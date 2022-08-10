# Pre-Installation

`lsblk` - for finding out which devices are present

`gdisk /dev/{device}` - to get drive ready for installation

`n` for new partition.

# First partition will be EFI

leave first sector default
EFI size partition will be `+550M`
code for EFI partition is `ef00`

### Second Partition will be SWAP

SWAP size partition will be `+1G`
code for SWAP partition is `8200`

### Third Patition will be root

root size parittion is up to the User
code for root partition is `8300` ( Linux filesystem )

### Fourth Partition will be /home

all defaults will be fine

write changes with `w`

### Formatting

We will be using `ext4` with the following commands

EFI Partition
`mkfs.vfat /dev/nvme1n1p1`

SWAP Partition
`mkswap /dev/nvme1n1p2`

Activate SWAP Partition
`swapon /dev/nvme1n1p2`

Root Partition
`mkfs.ext4 /dev/nvme1n1p3`

Same for /home partition
`mkfs.ext4 /dev/nvme1n1p4`

###Mount Partition

root partition goes on /mnt
`mount /dev/nvme1n1p3 /mnt`

create directories & mount boot
`mkdir -p /mnt/boot/efi`

then mount the boot drive
`mount /dev/nvme1n1p1 /mnt/boot/efi`

create directory for the /home
`mkdir /mnt/home`

then mount the /home direcotry
`mount /dev/nvme1n1p4 /mnt/home`

we don't need to mount SWAP partition

now `lsblk` to double check your mount points

### Install Base Packages into the root mount ( /mnt )

`pacstrap /mnt base linux linux-firmware git vim intel-ucode`

## Generate FileSystem Table

`genfstab -U /mnt >> /mnt/etc/fstab`

## Go into installation

`arch-chroot /mnt`

look at fstab file with
`cat /etc/fstab`

creat user
`useradd --create-home bit`
`passwd bit`
`usermod -aG wheel bit`
`visudo`

## Download and run install script

`git clone https://github.com/bitcode/arch.git`

reboot

# Post Installs

### DWM Flexipatch

`cd /usr/src/`
`git clone https://github.com/bakkeby/dwm-flexipatch.git`
`cd dwm-flexipatch`
`sudo make clean install`

### ST

`cd /usr/src/`
`git clone git://git.suckless.org/st`
`cd st`
`sudo make clean install`

### Install python packages with python pip

pip install -r /path/to/requirements.txt
pip3 install pynvim --upgrade
pip3 install openai

### rofi ( install is in basePacks )

rofi config is in: `~/.config/rofi/config.rasi`
more info @ `https://wiki.archlinux.org/title/Rofi#Configuration`

to add rofi to dwm lets edit config.h
`static const char *roficmd[] = { "rofi", "-show", "drun", "-show-icons", NULL };`
and
`{ MODKEY, XK_d, spawn, {.v = roficmd } },`

download gruvbox theme
git clone https://github.com/bardisty/gruvbox-rofi ~/.config/rofi/themes/gruvbox

use `rofi-theme-selector` to select the theme

get google chrome from AUR
`git clone https://aur.archlinux.org/google-chrome.git`
make the package with
`makepkg --syncdeps`
install downloaded file with
`pacman -U file_name`

# Install Nerd Font

`git clone https://github.com/ryanoasis/nerd-fonts.git`
`cd nerd-font`
`./install.sh`

# NPM packages

# NeoVim ( Install from build )

`git clone https://github.com/neovim/neovim.git`
`cd neovim`
`make CMAKE_BUILD_TYPE=RelWithDebInfo`
`sudo make install`

# ZSH + OhMyZsh

install zsh
`sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`

To list all installed shells
`chsh -l`
set zsh as default
`chsh -s path_to_zsh`

### ZSH Plugins

cd into `~/.oh-my-zsh/custom/plugins`
install zsh-autosuggestions
`git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`
Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
Install vim-mode
`https://github.com/softmoth/zsh-vim-mode.git`
Install zsh_codex
git clone https://github.com/tom-doerr/zsh_codex.git ~/.oh-my-zsh/custom/plugins/zsh_codex

### Tmux Plugin Manager TPM

`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
install with prefix + I

### Install PowerLovel10K

`git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k`

### Install Rust

`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

### Install ls-deluxe

`cargo install --git https://github.com/Peltoche/lsd.git --branch master`

### Install Vim Plug

`sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'`

### download and install dot files

make sure ~/.config/nvim folder exists
`git clone https://github.com/bitcode/dotfiles.git`
`stow zsh nvim tmux`

### download SecList from github

`git clone https://github.com/danielmiessler/SecLists.git`

### global npm packages

npm i -g @remix-project/remixd neovim bash-language-server pyright vscode-langservers-extracted typescript typescript-language-server emmet-ls

### install Neovim Plugin Manager Packer

`git clone --depth 1 https://github.com/wbthomason/packer.nvim\ ~/.local/share/nvim/site/pack/packer/start/packer.nvim`

### rofi configuration for dwm

`static const char *roficmd[] = { "rofi", "-show", "drun", "-show-icons", NULL };`
and
`{ MODKEY XK_d, spawn, {.v = roficmd } },`
in config.h. ( The last one goes into `static Key keys[] = {...` )

### things to do manually

1. Install Tmux plugins manually by pressing C-prefix then shift + I

### To see emojis in suckless

remove libxft
`sudo pacman -Rdd libxft`

### install libxft-bgra and lib32-libxft-bgra

cd /tmp
git clone https://aur.archlinux.org/lib32-libxft-bgra.git
makepkg -sri
if it fails to validate import key
`gpg --recv-key <key>`

### Manually install lua-language-server
https://github.com/sumneko/lua-language-server


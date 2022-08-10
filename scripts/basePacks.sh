#!/bin/bash

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf
echo "netopsbox" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 netopsbox.localdomain netopsbox" >> /etc/hosts
echo root:password | chpasswd

# You can add xorg to the installation packages, I usually add it at the DE or WM install script
# You can remove the tlp package if you are installing on a desktop or vm

pacman -S grub xorg efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers nvidia nvidia-utils nvidia-settings openssh openvpn rofi xorg-xinit base-devel cmake unzip ninja tree tree-sitter curl nodejs-lts-fermium zsh stow ranger okular highlight pygmentize python-pygments xdg-utils npm xsel python-pyx python-pip wget ripgrep fd lua luarocks go go-tools discord pipewire pipewire-pulse pipewire-alsa alsa-utils lib32-libpulse pyright cups usbutils

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer

printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"




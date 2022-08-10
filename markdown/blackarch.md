
# Install Blackarch on top of Arch

BlackArch Linux is compatible with existing/normal Arch installations. It acts as an unofficial user repository. Below you will find instructions on how to install BlackArch in this manner.

# Run https://blackarch.org/strap.sh as root and follow the instructions.

$ curl -O https://blackarch.org/strap.sh
# Verify the SHA1 sum

$ echo 46f035c31d758c077cce8f16cf9381e8def937bb strap.sh | sha1sum -c
# Set execute bit

$ chmod +x strap.sh
# Run strap.sh

$ sudo ./strap.sh
# Enable multilib following https://wiki.archlinux.org/index.php/Official_repositories#Enabling_multilib and run:

$ sudo pacman -Syu
You may now install tools from the blackarch repository.
# To list all of the available tools, run

$ sudo pacman -Sgg | grep blackarch | cut -d' ' -f2 | sort -u
# To install all of the tools, run

$ sudo pacman -S blackarch
# To install a category of tools, run

$ sudo pacman -S blackarch-<category>
# To see the blackarch categories, run

$ sudo pacman -Sg | grep blackarch
# Note - it maybe be necessary to overwrite certain packages when installing blackarch tools. If
# you experience "failed to commit transaction" errors, use the --needed and --overwrite switches
# For example:

$ sudo pacman -Syyu --needed blackarch --overwrite='*'

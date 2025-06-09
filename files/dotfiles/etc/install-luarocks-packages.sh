#!/usr/bin/env bash

# List of LuaRocks packages to install
luarocks_packages=(
  "luasocket"
  "luafilesystem"
  "jsregexp" # Add any other packages you need
)

# Loop through the list and install each package
for package in "${luarocks_packages[@]}"; do
  echo "Installing $package..."
  luarocks install "$package"
done

echo "All LuaRocks packages installed."

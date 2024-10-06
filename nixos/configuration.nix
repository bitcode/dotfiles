{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./programs.nix
    ./services.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixops";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  users.users.bit = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Allows sudo access
  };

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      nixos-unstable = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
      }) {};
    };
  };

  # Ensure the LuaRocks script is included in the configuration
  environment.etc."install-luarocks-packages.sh".source = ./install-luarocks-packages.sh;

  systemd.services.install-luarocks-packages = {
    description = "Install LuaRocks packages";
    after = [ "network.target" ]; # Ensure network is available
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash /etc/install-luarocks-packages.sh";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}

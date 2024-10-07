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
  };

  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "nixos-config=/etc/nixos/configuration.nix"
    "nixpkgs-unstable=/nix/var/nix/profiles/per-user/root/channels/nixpkgs"
  ];
}

{ config, pkgs, unstablePkgs, ... }:

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
      (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}


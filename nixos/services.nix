{ config, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      windowManager.i3.enable = true;
      xkb = {
        layout = "us";
        options = "caps:swapescape";
      };
    };

    displayManager.sddm.enable = true;
    openssh.enable = true;
  };

  programs.zsh.enable = true;
}


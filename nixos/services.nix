{ config, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;

      displayManager = {
        sddm.enable = true;
        sessionCommands = ''
          xrandr --output DP-2 --mode 1920x1080
          xrandr --dpi 120
        '';
      };

      windowManager.i3.enable = true;

      xkb = {
        layout = "us";
        options = "caps:swapescape";
      };
    };

    openssh.enable = true;
  };

  programs.zsh.enable = true;
}

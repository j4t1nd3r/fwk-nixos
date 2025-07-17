{ config, pkgs, inputs, ... }:

let
  ghost = ../assets/ghost_in_the_shell.jpeg;
  plasmaMgr = inputs.plasma-manager.packages.${pkgs.system}.default;
in
{
  home-manager.users.jat.xdg.configFile."autostart/set-wallpaper.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Set custom wallpaper
    Exec=plasma-apply-wallpaperimage ${ghost}
    X-KDE-autostart-phase=0
  '';
  home-manager.users.jat.programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel       = "org.kde.breezedark.desktop";
      wallpaperFillMode = "preserveAspectCrop";
      wallpaperBackground.blur = true;
    };
  };
}

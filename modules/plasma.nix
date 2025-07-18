# ./modules/plasma.nix

{ config, pkgs, inputs, ... }:

let
  backWp = ../assets/ghost_in_the_shell.jpeg;
  lockWp = ../assets/gorod-siluet-art-kiberpank.jpeg;
in
{

  home-manager.users.jat.xdg.configFile."autostart/set-wallpaper.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Set custom wallpaper
    Exec=plasma-apply-wallpaperimage ${backWp}
    X-KDE-autostart-phase=0
  '';

  home-manager.users.jat.xdg.configFile."kscreenlockerrc" = {
    force = true;
    text = ''
      [Greeter][Wallpaper][org.kde.image][General]
      Image=file://${lockWp}
      FillMode=2        # preserveAspectCrop
      Blur=true
    '';
  };

  home-manager.users.jat.programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel       = "org.kde.breezedark.desktop";
      wallpaperFillMode = "preserveAspectCrop";
      wallpaperBackground.blur = true;
    };
  };
}

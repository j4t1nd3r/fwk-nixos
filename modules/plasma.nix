# ./modules/plasma.nix
{ ... }:

{
  home-manager.users.jat.programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel              = "org.kde.breezedark.desktop";
      wallpaper                = ../assets/ghost_in_the_shell.jpeg;
      wallpaperFillMode        = "preserveAspectCrop";
      wallpaperBackground.blur = true;
    };
  };
}

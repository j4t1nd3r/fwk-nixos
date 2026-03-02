# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/nixos/plasma.nix

{ config, pkgs, inputs, ... }:

let
  backWp = ../../assets/wallhaven-jewmjp-regraded.jpg;
  lockWp = ../../assets/wallhaven-pky253-regraded.jpg;
in
{
  home-manager.users.jat.programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel          = "org.kde.breezedark.desktop";
      wallpaper            = backWp;
      wallpaperFillMode    = "preserveAspectCrop";
    };
    kscreenlocker.appearance.wallpaper = lockWp;
  };
}

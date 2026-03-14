# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/home/default.nix

{
  imports = [
    ./symlink.nix
    ./hyprland.nix
    ./waybar.nix
    ./waybar-style.nix
  ];
}

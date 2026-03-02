# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/nixos/default.nix

{
  imports = [
    ./sddm-pam.nix
    ./sddm-theme.nix
    ./plasma.nix
  ];
}

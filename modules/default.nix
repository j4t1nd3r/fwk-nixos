# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/default.nix

{
  imports = [
    ./sddm-pam.nix
    ./sddm-theme.nix
    ./plasma.nix
  ];
}

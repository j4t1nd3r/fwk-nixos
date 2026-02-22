# ./modules/default.nix

{
  imports = [
    ./sddm-pam.nix
    ./sddm-theme.nix
    ./plasma.nix
  ];
}

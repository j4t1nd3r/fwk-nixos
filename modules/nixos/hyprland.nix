# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/nixos/hyprland.nix

{ ... }:

{
  programs.hyprland = {
    enable          = true;
    withUWSM        = true;  # session management via UWSM (recommended ≥ 0.44)
    xwayland.enable = true;
  };

  # hyprpolkitagent requires polkit enabled at the system level
  security.polkit.enable = true;
}

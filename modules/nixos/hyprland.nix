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

  # kwallet: provides a libsecret-compatible keyring daemon so that apps
  # like VS Code and Signal can store credentials without keyring errors.
  # kwallet.enable unlocks the wallet at SDDM login via PAM so no manual
  # unlock prompt is needed after boot.
  security.pam.services.sddm.kwallet.enable = true;
}

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

  # gnome-keyring: provides a libsecret-compatible keyring daemon so that apps
  # like VS Code can store credentials without the "OS keyring couldn't be
  # identified" error.  enableGnomeKeyring unlocks the keyring at SDDM login
  # via PAM so no manual unlock prompt is needed after boot.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}

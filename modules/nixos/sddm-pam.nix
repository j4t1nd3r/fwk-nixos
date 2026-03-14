# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/nixos/sddm-pam.nix

{ lib, ... }:

{
  security.pam.services.sddm.text = lib.mkBefore ''
    auth sufficient pam_unix.so try_first_pass nullok
  '';

  # Fingerprint disabled in hyprlock PAM — handled natively via D-Bus
  # (auth { fingerprint {} } in hyprlock.conf). pam_fprintd in the PAM stack
  # causes input blocking during scan cycles. SDDM gets fprintd via
  # services.fprintd.enable in configuration.nix.
  security.pam.services.hyprlock.fprintAuth = false;
  security.pam.services.hyprlock.text = lib.mkForce ''
    auth optional  pam_faildelay.so delay=0
    auth required  pam_unix.so nullok
  '';
}

# SDDM: prepending pam_unix as sufficient lets a correct password short-circuit
# the stack before fprintd is reached, preventing a ~35s stall.
# Hyprlock: pam_fprintd first enables fingerprint unlock; pam_unix nullok is the
# password fallback. try_first_pass is intentionally omitted — hyprlock provides
# the password via its own PAM conversation, so no prior token exists on startup.
# Without this fix hyprlock would call pam_unix with a null token, fail immediately,
# and show the error message before the user has typed anything.

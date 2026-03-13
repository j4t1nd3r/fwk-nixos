# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/nixos/sddm-pam.nix

{ lib, ... }:

{
  security.pam.services.sddm.text = lib.mkBefore ''
    auth sufficient pam_unix.so try_first_pass nullok
  '';

  security.pam.services.hyprlock.text = lib.mkBefore ''
    auth sufficient pam_unix.so try_first_pass nullok
  '';
}

# Workaround: without this, the PAM stack hits fprintd after password entry,
# requiring a second (fingerprint) factor or causing a ~35s stall.
# Prepending pam_unix as sufficient lets a correct password short-circuit
# the stack before fprintd is reached.
# Applies to both SDDM (login) and hyprlock (screen unlock).
# nullok is safe as long as the user account has a password set.

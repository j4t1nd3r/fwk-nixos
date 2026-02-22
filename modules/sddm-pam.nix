# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/sddm-pam.nix

{ lib, ... }:

{
  security.pam.services.sddm.text = lib.mkBefore ''
    auth sufficient pam_unix.so try_first_pass nullok
  '';
}

# Workaround: without this, SDDM's PAM stack hits fprintd after password
# entry, requiring a second (fingerprint) factor or causing a stall.
# Prepending pam_unix as sufficient lets a correct password short-circuit
# the stack before fprintd is reached, so fingerprint works at login.
# nullok is safe as long as the user account has a password set.
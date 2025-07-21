# ./modules/sddm-pam.nix

{ lib, ... }:

{
  security.pam.services.sddm.text = lib.mkBefore ''
    # Check typed password first, but keep the normal stack
    auth sufficient pam_unix.so try_first_pass nullok
  '';
}


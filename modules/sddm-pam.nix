# ./modules/sddm-pam.nix

{ ... }:

{
  security.pam.services.sddm.text = ''
    auth    sufficient pam_unix.so      try_first_pass nullok
    auth    sufficient pam_fprintd.so
    auth    required   pam_deny.so

    account include  system-login
    password include system-login
    session  include system-login
  '';
}

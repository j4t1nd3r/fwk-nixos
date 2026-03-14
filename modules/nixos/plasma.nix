# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/nixos/plasma.nix

{ config, pkgs, inputs, ... }:

let
  backWp = ../../assets/wallhaven-jewmjp-regraded.jpg;
  lockWp = ../../assets/wallhaven-pky253-regraded.jpg;
in
{
  # Workaround: drkonqi-coredump-launcher crashes on every KDE login, producing a
  # "Service Crash" popup. The service integrates KDE's crash reporter with
  # systemd-coredump but fails under NixOS due to path/socket issues.
  # Overriding with a no-op service silences the crash notification.
  home-manager.users.jat.systemd.user.services.drkonqi-coredump-launcher = {
    Unit.Description = "drkonqi coredump launcher (masked)";
    Service = {
      Type       = "oneshot";
      ExecStart  = "${pkgs.coreutils}/bin/true";
    };
  };

  home-manager.users.jat.programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel          = "org.kde.breezedark.desktop";
      wallpaper            = backWp;
      wallpaperFillMode    = "preserveAspectCrop";
    };
    kscreenlocker.appearance.wallpaper = lockWp;
  };
}

# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/nixos/plasma.nix

{ config, pkgs, inputs, ... }:

let
  backWp = ../../assets/wallhaven-pky253.jpg;
  lockWp = ../../assets/wallhaven-pky253-regraded.jpg;
in
{
  # Workaround: drkonqi-coredump-launcher crashes on every KDE login, producing a
  # "Service Crash" popup. The socket drkonqi-coredump-launcher.socket listens at
  # login and activates template instances (drkonqi-coredump-launcher@.service)
  # that run the real binary, which fails under NixOS. Overriding the template
  # with a no-op stops the crash; the non-template override is kept as a fallback.
  home-manager.users.jat.systemd.user.services.drkonqi-coredump-launcher = {
    Unit.Description = "drkonqi coredump launcher (masked)";
    Service = {
      Type      = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
  };
  home-manager.users.jat.systemd.user.services."drkonqi-coredump-launcher@" = {
    Unit.Description = "drkonqi coredump launcher template (masked)";
    Service = {
      Type      = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/true";
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

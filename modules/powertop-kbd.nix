# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/powertop-kbd.nix

# powertop auto-tune sets all USB devices to autosuspend on boot, which
# causes key drops and lag on the Framework 16 USB keyboard module (USB HID,
# vendor 32ac product 0018). Two-part fix:
#   1. udev rule — fires on device add/hot-plug, sets power/control to on
#   2. systemd service — runs after powertop.service, overrides the auto-tune
{ pkgs, ... }:

{
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", \
      ATTR{idVendor}=="32ac", ATTR{idProduct}=="0018", \
      ATTR{power/control}="on"
  '';

  systemd.services.framework-kbd-usb-power = {
    description = "Keep Framework 16 keyboard USB always-on (override powertop)";
    after       = [ "powertop.service" ];
    wants       = [ "powertop.service" ];
    wantedBy    = [ "multi-user.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "framework-kbd-usb-power" ''
        for vendor in /sys/bus/usb/devices/*/idVendor; do
          if [ "$(cat "$vendor")" = "32ac" ]; then
            dir=$(dirname "$vendor")
            if [ "$(cat "$dir/idProduct" 2>/dev/null)" = "0018" ]; then
              echo on > "$dir/power/control"
            fi
          fi
        done
      '';
    };
  };
}

# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/powertop-kbd.nix

# Framework 16 USB keyboard module (vendor 32ac, product 0018) suffers from
# USB autosuspend: the kernel's in-kernel autosuspend mechanic (independent of
# powertop) idles the device after ~2 s, causing:
#   - first keypress not registering  (wake consumes the event)
#   - stuck/repeating keys ("rrrrrr") (stale HID report replayed on wake)
#
# Root cause: powertop.enableAutoTune sets ALL USB devices to autosuspend=2s
# at boot. Even after powertop exits, the kernel continues enforcing it.
# Writing "on" to power/control is overridden as soon as autosuspend fires again.
#
# Fix strategy (defence in depth):
#   1. Kernel quirk (usbcore.quirks) — marks the device USB_QUIRK_NO_AUTOSUSPEND
#      (bit 26, 0x4000000) at the kernel level before any userspace runs.
#      This is the primary fix and is immune to powertop or any sysfs write.
#   2. udev rules — belt-and-suspenders for hot-plug (add) and any runtime
#      sysfs change (change). NOTE: udev == is an exact match, NOT a regex;
#      "add|change" does NOT work — two separate rules are required.
#   3. systemd service — re-applies at boot after powertop.service (ordering only).
#   4. powerManagement.resumeCommands — re-applies after every suspend/resume.
#      (wantedBy=suspend.target fires on the way INTO suspend, not on wake.)
{ pkgs, ... }:

let
  fixScript = pkgs.writeShellScript "framework-kbd-usb-power" ''
    for vendor in /sys/bus/usb/devices/*/idVendor; do
      if [ "$(cat "$vendor")" = "32ac" ]; then
        dir=$(dirname "$vendor")
        if [ "$(cat "$dir/idProduct" 2>/dev/null)" = "0018" ]; then
          echo on > "$dir/power/control"
        fi
      fi
    done
  '';
in
{
  # Primary fix: kernel-level quirk — USB_QUIRK_NO_AUTOSUSPEND = bit 26 = 0x4000000
  # Format: vendorId:productId:quirk-flags (hex, no leading 0x in kernel param)
  # This prevents the kernel from ever autosuspending this specific device.
  boot.kernelParams = [ "usbcore.quirks=32ac:0018:0x4000000" ];

  # DISABLED for isolation test: if the keyboard issue disappears after rebuild,
  # powertop was the root cause and these workarounds + the quirk are the correct fix.
  # Re-enable once confirmed.

  # services.udev.extraRules = ''
  #   ACTION=="add",    SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0018", ATTR{power/control}="on"
  #   ACTION=="change", SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0018", ATTR{power/control}="on"
  # '';

  # systemd.services.framework-kbd-usb-power = {
  #   description = "Keep Framework 16 keyboard USB always-on (override powertop)";
  #   after    = [ "powertop.service" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type            = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart       = fixScript;
  #   };
  # };

  # powerManagement.resumeCommands = ''
  #   ${fixScript}
  # '';
}

# bugs

## active

---

### drkonqi-coredump-launcher crashes on every KDE login

**status:** workaround active  
**file:** `modules/nixos/plasma.nix`

**description:**  
On every login to KDE Plasma, a "Service Crash" notification appears for
`drkonqi-coredump-launcher`. The service is KDE's crash-reporter integration
with systemd-coredump; it activates via D-Bus at session start but immediately
crashes under NixOS due to path or socket issues in the Nix store environment.

**current workaround:**  
The crash comes from socket-activated template instances
(`drkonqi-coredump-launcher@.service`), not the non-template unit. Both the
template and the non-template service are overridden with no-ops:

```nix
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
```

Side-effect: KDE crash reports are no longer collected via the coredump
integration path (manual bug reports via drkonqi still work).

**proper fix:**  
Upstream NixOS drkonqi package or service configuration. Monitor:
https://github.com/NixOS/nixpkgs/issues (search: drkonqi coredump NixOS)

---

### powertop USB autosuspend disables Framework 16 keyboard

**status:** workaround active — powertop disabled  
**file:** `nixos/configuration.nix`

**description:**  
Enabling `powerManagement.powertop.enable = true;` applies blanket USB autosuspend
to all devices. The Framework 16 keyboard (USB vendor `32ac`, product `0018`) gets
suspended and becomes unresponsive until physically unplugged and replugged or
the machine is rebooted.

**current workaround:**  
`powerManagement.powertop.enable` is commented out, losing all powertop
auto-tune battery savings across the rest of the system.

**proper fix (not yet implemented):**  
Add a udev rule that explicitly sets the USB autosuspend policy for `32ac:0018`
to `on` (disabled) before powertop runs, allowing powertop to be re-enabled:

```nix
services.udev.extraRules = ''
  # Disable USB autosuspend for Framework 16 keyboard (32ac:0018)
  ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0018", \
  ATTR{power/control}="on"
'';
```

Then re-enable:
```nix
powerManagement.powertop.enable = true;
```

**references:**  
- https://github.com/NixOS/nixpkgs (udev.extraRules)  
- Framework community: known issue with input module USB IDs and powertop

---

### AMDGPU DCN 3.1.4 graphical artifacts under Plasma 6.6+

**status:** workaround active  
**file:** `nixos/configuration.nix`

**description:**  
AMDGPU's DCN 3.1.4 display engine loses floating-point precision when
KWin programs the hardware display shaper LUT (look-up table) introduced
in Plasma 6.6. Results in intermittent colour banding / graphical corruption
on the display.

**current workaround:**  
```nix
environment.sessionVariables.KWIN_DRM_NO_AMS = "1";
```
This disables KWin's hardware colour management, routing colour transforms
through software instead. Functional but prevents use of hardware HDR/wide
colour gamut features.

**proper fix:**  
Upstream amdgpu kernel driver fix or KWin workaround for DCN 3.1.4 precision.
Monitor: https://bugs.kde.org and https://gitlab.freedesktop.org/drm/amd/issues

---

## resolved

<!-- move items here once fixed, include fix date and commit/PR ref -->

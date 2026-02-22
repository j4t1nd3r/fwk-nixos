# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/sddm-theme.nix

{ pkgs, ... }:

let
  sddmAstronautCp = pkgs.sddm-astronaut.override { embeddedTheme = "cyberpunk"; };
in
{
  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;
    theme          = "sddm-astronaut-theme";
    extraPackages  = [ sddmAstronautCp ];
    settings = {
      Theme.CursorTheme     = "Breeze_Snow";
      General.HaltCommand   = "systemctl poweroff";
      General.RebootCommand = "systemctl reboot";
    };
  };
}

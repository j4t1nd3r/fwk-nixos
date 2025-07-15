# ./modules/sddm.nix

{ pkgs, ... }:

let
  sddmAstronautCp = pkgs.sddm-astronaut.override { embeddedTheme = "cyberpunk"; };
in
{
  environment.systemPackages = [ sddmAstronautCp ];

  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;
    theme          = "sddm-astronaut-theme";
    extraPackages  = [ sddmAstronautCp ];
    settings = {
      Theme.CursorTheme   = "Breeze_Snow";
      General.HaltCommand = "systemctl poweroff";
      General.RebootCommand = "systemctl reboot";
    };
  };
}

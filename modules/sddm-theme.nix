# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/sddm-theme.nix

{ pkgs, ... }:

let
  sddmTheme = pkgs.sddm-astronaut.override { embeddedTheme = "japanese_aesthetic"; };
in
{
  # extraPackages puts the package on SDDM's Qt lib path (needed for the greeter),
  # but the ThemeDir (/run/current-system/sw/share/sddm/themes) is only populated
  # from environment.systemPackages — both are required for the theme to load.
  environment.systemPackages = [ sddmTheme ];

  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;
    theme          = "sddm-astronaut-theme";
    extraPackages  = [ sddmTheme ];
    settings = {
      Theme.CursorTheme     = "Breeze_Snow";
      General.HaltCommand   = "systemctl poweroff";
      General.RebootCommand = "systemctl reboot";
    };
  };
}

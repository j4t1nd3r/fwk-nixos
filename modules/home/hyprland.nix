# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/home/hyprland.nix

{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar                # status bar
    wofi                  # app launcher  (bound to $mod + R)
    hyprpaper             # wallpaper daemon
    hyprlock              # screen locker
    hypridle              # idle daemon   (triggers hyprlock)
    hyprpolkitagent       # polkit agent
    grim                  # screenshot (grab)
    slurp                 # screenshot (region select)
    mako                  # notification daemon
    libnotify             # notify-send (test notifications)
    networkmanagerapplet  # nm-applet tray icon
    brightnessctl         # display brightness keybinds
    playerctl             # media key support
  ];

  services.mako = {
    enable         = true;
    defaultTimeout = 5000;  # ms
  };

  # Use the package installed by the NixOS module (programs.hyprland)
  # to avoid version mismatches between the compositor and portal.
  wayland.windowManager.hyprland = {
    enable        = true;
    package       = null;  # defer to programs.hyprland package from NixOS module
    portalPackage = null;  # defer to programs.hyprland portalPackage from NixOS module

    settings = {
      "$mod" = "SUPER";

      monitor = ",preferred,auto,1";  # auto-detect, native res, 1× scale (bump to 1.25/1.5 for HiDPI)

      general = {
        gaps_in             = 5;
        gaps_out            = 10;
        border_size         = 2;
        "col.active_border"   = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout              = "dwindle";
      };

      decoration = {
        rounding       = 8;
        blur.enabled   = true;
        blur.size      = 3;
        blur.passes    = 1;
      };

      animations = {
        enabled = true;
      };

      misc = {
        disable_hyprland_logo   = true;
        disable_splash_rendering = true;
      };

      dwindle = {
        pseudotile     = true;
        preserve_split = true;
      };

      input = {
        kb_layout = "gb";  # matches services.xserver.xkb.layout in configuration.nix
        touchpad = {
          natural_scroll   = true;
          disable_while_typing = true;
        };
      };

      # ── keybinds ──────────────────────────────────────────────────────────

      bind =
        [
          # apps
          "$mod, Return, exec, kitty"
          "$mod, R, exec, wofi --show run"

          # window management
          "$mod, Q, killactive"
          "$mod, M, exit"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"
          "$mod, P, pseudo"          # dwindle pseudotile
          "$mod, J, togglesplit"     # dwindle split direction

          # focus
          "$mod, left,  movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up,    movefocus, u"
          "$mod, down,  movefocus, d"

          # move windows
          "$mod SHIFT, left,  movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up,    movewindow, u"
          "$mod SHIFT, down,  movewindow, d"

          # screenshot (region → clipboard)
          ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"

          # brightness (Framework 16 backlight)
          ", XF86MonBrightnessUp,   exec, brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

          # media keys
          ", XF86AudioPlay,  exec, playerctl play-pause"
          ", XF86AudioNext,  exec, playerctl next"
          ", XF86AudioPrev,  exec, playerctl previous"
        ]
        ++ (
          # $mod + [1-9]         → switch to workspace
          # $mod + Shift + [1-9] → move window to workspace
          builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod,       code:1${toString i}, workspace,        ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace,  ${toString ws}"
            ]
          ) 9)
        );

      # mouse binds
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # autostart
      exec-once = [
        "waybar"
        "hyprpaper"
        "hypridle"
        "hyprpolkitagent"
        "mako"
        "nm-applet --indicator"
      ];
    };
  };

  # Forward home-manager session variables into the UWSM environment so that
  # programs launched via systemd user services inherit PATH, EDITOR, etc.
  # Required when programs.hyprland.withUWSM = true (NixOS module).
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
}

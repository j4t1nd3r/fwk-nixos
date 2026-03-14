# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/home/hyprland.nix

{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar                # status bar
    rofi                  # app launcher  (bound to $mod + R)
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
    enable    = true;
    settings.default-timeout = 5000;  # ms
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
          "$mod, R, exec, bash ~/.config/rofi/launch.sh"

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
          "$mod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"

          # brightness (Framework kb: Fn+F8 up, Fn+F7 down → XF86 keysyms)
          ", XF86MonBrightnessUp,   exec, brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

          # volume keys (Framework kb: Fn+F1 mute, Fn+F2 down, Fn+F3 up)
          ", XF86AudioMute,        exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
          ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
          ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"

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
        "kwalletd6"
      ];
    };
  };

  # ── Rofi (app launcher) ─────────────────────────────────────────────────────

  # Categorised launcher: reads .desktop Categories + Icon fields, colours
  # entries with Pango markup and passes icon names via rofi's dmenu format,
  # giving both coloured text and app icons simultaneously.
  home.file.".config/rofi/launch.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # ── Category → Catppuccin Mocha colour mapping ───────────────────────
      color_for_cats() {
        case "$1" in
          *AudioVideo*|*Audio*|*Video*|*Music*)  echo "#cba6f7" ;; # purple   — media
          *Development*|*IDE*)                   echo "#89b4fa" ;; # blue     — dev
          *Network*|*Chat*|*InstantMessaging*)   echo "#94e2d5" ;; # teal     — messaging
          *TerminalEmulator*|*System*)           echo "#f5c2e7" ;; # pink     — system
          *Office*|*TextEditor*)                 echo "#b4befe" ;; # lavender — office
          *Game*)                                echo "#f38ba8" ;; # red      — games
          *Graphics*|*Photography*)              echo "#f9e2af" ;; # yellow   — graphics
          *Settings*)                            echo "#a6e3a1" ;; # green    — settings
          *)                                     echo "#cdd6f4" ;; # default
        esac
      }

      # ── Blocklist — apps not wanted in launcher ───────────────────────────
      BLOCKLIST=(
        # KDE utilities pulled in as deps
        "Ark"
        "Filelight"
        "ISO Image Writer"
        "KDE Partition Manager"
        # network / tray helpers (used internally, not launched directly)
        "Advanced Network Configuration"
        "NetworkManager Applet"
        "pwvucontrol"
        # browser/app sub-entries
        "kitty URL Launcher"
        "New Window"
        "New Empty Window"
        "New Incognito Window"
        "Visual Studio Code - URL Handler"
        # rofi own entries
        "Rofi"
        "Rofi Theme Selector"
      )
      is_blocked() {
        local n="$1"
        for b in "''${BLOCKLIST[@]}"; do [[ "$n" == "$b" ]] && return 0; done
        return 1
      }

      # ── Display name overrides (fix upstream .desktop names) ──────────────
      declare -A NAME_OVERRIDE
      NAME_OVERRIDE["kitty"]="Kitty"

      # ── Collect .desktop entries ──────────────────────────────────────────
      declare -A NAME_TO_ID
      declare -A NAME_TO_CATS
      declare -A NAME_TO_ICON
      declare -A NAME_TO_FILE   # full path to .desktop file
      # Only scan user-installed app dirs — avoids hundreds of KDE/system
      # desktop files in /run/current-system/sw/share/applications.
      DIRS=(
        "/etc/profiles/per-user/$USER/share/applications"
        "$HOME/.local/share/applications"
      )

      for dir in "''${DIRS[@]}"; do
        [[ -d "$dir" ]] || continue
        for f in "$dir"/*.desktop; do
          [[ -f "$f" ]] || continue
          name=$(grep -m1 "^Name=" "$f" | cut -d= -f2-)
          nodisplay=$(grep -m1 "^NoDisplay=" "$f" 2>/dev/null | cut -d= -f2-)
          terminal=$(grep -m1 "^Terminal=" "$f" 2>/dev/null | cut -d= -f2-)
          onlyshowin=$(grep -m1 "^OnlyShowIn=" "$f" 2>/dev/null | cut -d= -f2-)

          [[ -z "$name" || "$nodisplay" == "true" ]] && continue
          [[ "$terminal" == "true" ]] && continue
          [[ -n "$onlyshowin" && "$onlyshowin" != *"Hyprland"* && "$onlyshowin" == *"KDE"* ]] && continue
          is_blocked "$name" && continue
          name="''${NAME_OVERRIDE[$name]:-$name}"

          [[ -n "''${NAME_TO_ID[$name]+x}" ]] && continue  # first found wins
          NAME_TO_ID["$name"]=$(basename "$f" .desktop)
          NAME_TO_FILE["$name"]="$f"
          NAME_TO_CATS["$name"]=$(grep -m1 "^Categories=" "$f" 2>/dev/null | cut -d= -f2- || true)
          NAME_TO_ICON["$name"]=$(grep -m1 "^Icon=" "$f" 2>/dev/null | cut -d= -f2- || true)
        done
      done

      # ── Pipe menu directly to rofi ───────────────────────────────────────────────
      # Must pipe directly — bash $() strips null bytes, breaking the
      # \x00icon\x1f<name> format rofi uses to associate icons with entries.
      selected=$(printf '%s\n' "''${!NAME_TO_ID[@]}" | sort | while IFS= read -r name; do
        color=$(color_for_cats "''${NAME_TO_CATS[$name]:-}")
        icon="''${NAME_TO_ICON[$name]:-}"
        printf '<span foreground="%s">%s</span>\x00icon\x1f%s\n' "$color" "$name" "$icon"
      done | rofi -dmenu -markup-rows -show-icons -i -p "" \
        -theme "$HOME/.config/rofi/theme.rasi") || exit 0

      plain=$(printf '%s' "$selected" | sed 's/<[^>]*>//g')
      [[ -z "$plain" ]] && exit 0

      desktop_file="''${NAME_TO_FILE[$plain]:-}"
      [[ -z "$desktop_file" ]] && exit 0

      # Parse Exec= and strip field codes (%u %U %f %F etc.), then launch
      exec_line=$(grep -m1 "^Exec=" "$desktop_file" | cut -d= -f2- | sed 's/ %[a-zA-Z]//g')
      [[ -z "$exec_line" ]] && exit 0
      setsid bash -c "$exec_line" &
    '';
  };

  xdg.configFile."rofi/theme.rasi".text = ''
    /* Catppuccin Mocha — matches waybar theme */
    * {
      bg0:        #151520;   /* background2 */
      bg1:        #202030;   /* background1 */
      border-col: #313244;
      fg:         #cdd6f4;
      accent:     #b4befe;   /* lavender */
      subtle:     #585b70;

      background-color: transparent;
      text-color:       @fg;
      font:             "JetBrainsMono Nerd Font propo 12";
      border:           0;
      margin:           0;
      padding:          0;
      spacing:          0;
    }

    window {
      background-color: @bg0;
      border:           1px;
      border-color:     @border-col;
      border-radius:    8px;
      width:            600px;
    }

    mainbox {
      children: [ inputbar, listview ];
    }

    inputbar {
      background-color: @bg1;
      border-radius:    8px 8px 0 0;
      border:           0 0 1px 0;
      border-color:     @border-col;
      padding:          8px 12px;
      children:         [ entry ];
    }

    entry {
      text-color:        @fg;
      placeholder:       "Search...";
      placeholder-color: @subtle;
    }

    listview {
      padding:      4px 0;
      lines:        10;
      fixed-height: false;
      scrollbar:    false;
    }

    element {
      padding:      6px 12px;
      border-radius: 4px;
      margin:       0 4px;
      spacing:      10px;
      children:     [ element-icon, element-text ];
    }

    element selected {
      background-color: @bg1;
    }

    element-icon {
      size:           22px;
      vertical-align: 0.5;
    }

    element-text {
      vertical-align: 0.5;
      highlight:      bold #b4befe;
    }
  '';

  # Forward home-manager session variables into the UWSM environment so that
  # programs launched via systemd user services inherit PATH, EDITOR, etc.
  # Required when programs.hyprland.withUWSM = true (NixOS module).
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
      lock_cmd         = pidof hyprlock || hyprlock  # don't spawn multiple instances
      before_sleep_cmd = loginctl lock-session        # lock before suspend
      after_sleep_cmd  = hyprctl dispatch dpms on     # wake display after resume
    }

    listener {
      timeout  = 150                                  # 2.5 min: dim screen
      on-timeout  = brightnessctl -s set 20%
      on-resume   = brightnessctl -r
    }

    listener {
      timeout  = 300                                  # 5 min: lock screen
      on-timeout  = loginctl lock-session
    }

    listener {
      timeout  = 360                                  # 6 min: display off
      on-timeout  = hyprctl dispatch dpms off
      on-resume   = hyprctl dispatch dpms on
    }

    listener {
      timeout  = 900                                  # 15 min: suspend
      on-timeout  = systemctl suspend
    }
  '';

  # DrKonqi (KDE crash handler) crashes on Hyprland because there's no KDE session,
  # creating a cascade crash loop. Mask it since we use journalctl/coredumpctl instead.
  home.activation.maskDrkonqi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD systemctl --user mask --now \
      drkonqi-coredump-launcher.socket \
      drkonqi-sentry-postman.path \
      2>/dev/null || true
  '';
}

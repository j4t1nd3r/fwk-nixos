# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/home/hyprland.nix

{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar                # status bar
    rofi                  # app launcher  (bound to $mod + R)
    swaybg                # wallpaper daemon
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
    wl-clipboard          # wl-copy/wl-paste (used in screenshot binds)
    pulseaudio            # pactl for volume keybinds
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
        gaps_out            = 5;
        border_size         = 2;
        "col.active_border"   = "rgba(b4befe90) rgba(cba6f790) 45deg";
        "col.inactive_border" = "rgba(45475aaa)";
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
        disable_hyprland_logo    = true;
        disable_splash_rendering = true;
        vfr                      = true;
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
          "$mod, L, exec, loginctl lock-session"

          # window management
          "$mod, Q, killactive"
          "$mod, M, exec, uwsm stop"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"
          "$mod, P, pseudo"          # dwindle pseudotile
          "$mod, J, togglesplit"     # dwindle split direction
          "$mod, TAB, cyclenext"     # cycle through windows

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

          # screenshot (region → clipboard; silent if slurp cancelled)
          ", Print, exec, slurp | xargs -I{} grim -g {} - | wl-copy"
          "$mod SHIFT, S, exec, slurp | xargs -I{} grim -g {} - | wl-copy"

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
        "swaybg -i ${config.home.homeDirectory}/.config/wallpaper.jpg -m fill"
        "hypridle"
        "hyprpolkitagent"
        "mako"
        "nm-applet --indicator"
        "kwalletd6"
        "bash $HOME/.config/rofi/build-cache.sh"
      ];
    };
  };

  # ── Rofi (app launcher) ─────────────────────────────────────────────────────

  # build-cache.sh — scans .desktop files and writes:
  #   ~/.cache/rofi/menu       — pre-built Pango markup lines for rofi
  #   ~/.cache/rofi/lookup     — tab-separated "display name → desktop file path"
  # Called at session start (exec-once) and in the background after each launch.
  home.file.".config/rofi/build-cache.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      CACHE_DIR="$HOME/.cache/rofi"
      mkdir -p "$CACHE_DIR"

      # ── Category → Catppuccin Mocha colour mapping ───────────────────────
      color_for_cats() {
        case "$1" in
          *AudioVideo*|*Audio*|*Video*|*Music*)  echo "#cba6f7" ;;
          *Development*|*IDE*)                   echo "#89b4fa" ;;
          *Network*|*Chat*|*InstantMessaging*)   echo "#94e2d5" ;;
          *TerminalEmulator*|*System*)           echo "#f5c2e7" ;;
          *Office*|*TextEditor*)                 echo "#b4befe" ;;
          *Game*)                                echo "#f38ba8" ;;
          *Graphics*|*Photography*)              echo "#f9e2af" ;;
          *Settings*)                            echo "#a6e3a1" ;;
          *)                                     echo "#cdd6f4" ;;
        esac
      }

      BLOCKLIST=(
        "Ark" "Filelight" "ISO Image Writer" "KDE Partition Manager"
        "Advanced Network Configuration" "NetworkManager Applet" "pwvucontrol"
        "kitty URL Launcher" "New Window" "New Empty Window" "New Incognito Window"
        "Visual Studio Code - URL Handler" "Rofi" "Rofi Theme Selector"
      )
      is_blocked() {
        local n="$1"
        for b in "''${BLOCKLIST[@]}"; do [[ "$n" == "$b" ]] && return 0; done
        return 1
      }

      declare -A NAME_OVERRIDE
      NAME_OVERRIDE["kitty"]="Kitty"

      declare -A NAME_TO_FILE
      declare -A NAME_TO_CATS

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

          [[ -n "''${NAME_TO_FILE[$name]+x}" ]] && continue
          NAME_TO_FILE["$name"]="$f"
          NAME_TO_CATS["$name"]=$(grep -m1 "^Categories=" "$f" 2>/dev/null | cut -d= -f2- || true)
        done
      done

      # Write menu (sorted markup lines) and lookup (name<TAB>path)
      : > "$CACHE_DIR/menu"
      : > "$CACHE_DIR/lookup"
      while IFS= read -r name; do
        color=$(color_for_cats "''${NAME_TO_CATS[$name]:-}")
        printf '<span foreground="%s">%s</span>\n' "$color" "$name" >> "$CACHE_DIR/menu"
        printf '%s\t%s\n' "$name" "''${NAME_TO_FILE[$name]}" >> "$CACHE_DIR/lookup"
      done < <(printf '%s\n' "''${!NAME_TO_FILE[@]}" | sort)
    '';
  };

  # launch.sh — reads cache and shows rofi instantly; rebuilds cache in background.
  home.file.".config/rofi/launch.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      CACHE_DIR="$HOME/.cache/rofi"

      # Build cache on first run if missing
      if [[ ! -f "$CACHE_DIR/menu" ]]; then
        bash "$HOME/.config/rofi/build-cache.sh"
      fi

      selected=$(rofi -dmenu -markup-rows -i -p "" \
        -theme "$HOME/.config/rofi/theme.rasi" \
        < "$CACHE_DIR/menu") || exit 0

      plain=$(printf '%s' "$selected" | sed 's/<[^>]*>//g')
      [[ -z "$plain" ]] && exit 0

      desktop_file=$(grep -m1 "^''${plain}	" "$CACHE_DIR/lookup" | cut -f2-)
      [[ -z "$desktop_file" || ! -f "$desktop_file" ]] && exit 0

      exec_line=$(grep -m1 "^Exec=" "$desktop_file" | cut -d= -f2- | sed 's/ %[a-zA-Z]//g')
      [[ -z "$exec_line" ]] && exit 0
      setsid bash -c "$exec_line" &

      # Rebuild cache in background for next launch
      bash "$HOME/.config/rofi/build-cache.sh" &
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
      children:     [ element-text ];
    }

    element selected {
      background-color: @bg1;
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

  # ── Wallpaper ────────────────────────────────────────────────────────────────
  home.file.".config/wallpaper.jpg".source        = ../../assets/wallhaven-pky253.jpg;
  home.file.".config/wallpaper-lock.jpg".source   = ../../assets/wallhaven-pky253-regraded.jpg;

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
      lock_cmd         = pidof hyprlock || hyprlock  # don't spawn multiple instances
      before_sleep_cmd = loginctl lock-session        # lock before suspend
      after_sleep_cmd  = hyprctl dispatch dpms on && (pidof hyprlock || hyprlock)  # wake display then ensure locked
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

  # ── Hyprlock (lock screen) ──────────────────────────────────────────────────
  xdg.configFile."hypr/hyprlock.conf".text = ''
    # Catppuccin Mocha — blurred wallpaper background
    background {
      monitor     =
      path        = ${config.home.homeDirectory}/.config/wallpaper-lock.jpg
      blur_passes = 1
      blur_size   = 2
      brightness  = 0.4
      color       = rgba(17171bff)   # crust fallback
    }

    # Clock
    label {
      monitor     =
      text        = cmd[update:1000] echo "<b>$(date +'%H:%M')</b>"
      color       = rgba(b4befeff)   # lavender
      font_size   = 90
      font_family = JetBrainsMono Nerd Font
      position    = 0, 80
      halign      = center
      valign      = center
    }

    # Date
    label {
      monitor     =
      text        = cmd[update:60000] echo "$(date +'%A, %d %B %Y')"
      color       = rgba(a6adc8ff)   # subtext1
      font_size   = 18
      font_family = JetBrainsMono Nerd Font
      position    = 0, -20
      halign      = center
      valign      = center
    }

    # Password input — invisible at rest, themed border appears as feedback
    input-field {
      monitor            =
      size               = 300, 52
      rounding           = 8
      outline_thickness  = 2
      dots_size          = 0.25
      dots_spacing       = 0.2
      outer_color        = rgba(45475aff)   # surface1 — idle border
      inner_color        = rgba(1e1e2eff)   # mantle
      font_color         = rgba(cdd6f4ff)   # text
      check_color        = rgba(b4befeff)   # lavender — PAM checking
      fail_color         = rgba(f38ba8ff)   # red — wrong password
      capslock_color     = rgba(f9e2afff)   # yellow — caps lock on
      fade_on_empty      = true
      ignore_empty_input = true
      placeholder_text   =
      fail_text          =
      position           = 0, -160
      halign             = center
      valign             = center
    }

    # Fingerprint — native D-Bus, silent, activates on touch
    auth {
      fingerprint {
        enabled         = true
        ready_message   =
        present_message =
        error_message   =
      }
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

# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/home/waybar.nix
#
# Waybar config adapted from Jan-Aarela's Mocha-Power theme:
# https://github.com/Jan-Aarela/dotfiles/tree/main/hypr/themes/Mocha-Power
#
# Adaptations for Framework 16 AMD:
#   - Removed: nvidia, headsetbattery, cava, timer modules
#   - Replaced: custom/battery uses bat-pp.sh (AMD-compatible, no custom script deps)
#   - Removed: intel_backlight device lock (auto-detect)
#   - Indicator bar padding: (2560/1) - 0 - 24 - 2*2.5 - (10/2) = 2526px

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wttrbar                   # weather module  (custom/weather → wttrbar --nerd)
    pwvucontrol               # PipeWire vol control (right-click audio modules)
    pulseaudio                # pactl for volume keybinds/audio modules
    nerd-fonts.jetbrains-mono # bar font
  ];

  # ── Main bar + indicator bar config ─────────────────────────────────────────

  xdg.configFile."waybar/config.jsonc".text = ''
    [
      {
        // MAIN BAR
        "layer": "top",
        "position": "top",
        "name": "main",
        "height": 28,
        "reload_style_on_change": true,

        "margin-top": 24,
        "margin-left": 24,
        "margin-right": 24,

        "modules-left": [
          "group/traym",
          "hyprland/workspaces",
          "hyprland/submap",
          "hyprland/window"
        ],

        "modules-right": [
          "custom/spacer1",
          "cpu",
          "temperature",
          "memory#ram",
          "memory#swap",
          "disk",
          "network#info",
          "custom/spacer2",
          "pulseaudio#input",
          "group/vol-out",
          "custom/spacer3",
          "backlight",
          "custom/battery",
          "custom/spacer4",
          "clock",
          "custom/weather"
        ],

        // ── Modules ────────────────────────────────────────────────────────

        "disk": {
          "interval": 16,
          "format": " {percentage_used}%",
          "tooltip-format": "Free {free}",
          "states": { "warning": 85, "critical": 95 }
        },

        "custom/weather": {
          "format": "{}°",
          "tooltip": true,
          "interval": 60,
          "exec": "wttrbar --nerd --location Leeds",
          "return-type": "json"
        },

        "group/traym": {
          "orientation": "horizontal",
          "drawer": {},
          "modules": ["custom/trayicon", "tray"]
        },

        "backlight": {
          "format": "{icon} {percent}%",
          "format-icons": ["󱩎", "󱩑", "󱩓", "󱩕", "󰛨"],
          "scroll-step": 1,
          "on-scroll-up":   "brightnessctl set 2%-",
          "on-scroll-down": "brightnessctl set +2%"
        },

        "custom/battery": {
          "interval": 8,
          "return-type": "json",
          "exec": "~/.config/waybar/bat-pp.sh refresh",
          "exec-on-event": true,
          "format": "{text}%",
          "on-click": "~/.config/waybar/bat-pp.sh toggle",
          "tooltip": true,
          "tooltip-format": "{alt}"
        },

        "clock": {
          "interval": 1,
          "format": " {:%H:%M:%S    %a %d.%m}",
          "tooltip-format": "{calendar}",
          "calendar": {
            "weeks-pos": "right",
            "mode": "month",
            "format": {
              "months":   "<span color='#cba6f7'><b>{}</b></span>",
              "days":     "<span color='#cdd6f4'><b>{}</b></span>",
              "weeks":    "<span color='#94e2d5'> W{}</span>",
              "weekdays": "<span color='#f9e2af'><b>{}</b></span>",
              "today":    "<span color='#f5e0dc'><b><u>{}</u></b></span>"
            }
          }
        },

        "cpu": {
          "interval": 4,
          "min-length": 6,
          "format": " {usage}%",
          "states": { "warning": 80, "critical": 95 }
        },

        "memory#ram": {
          "interval": 4,
          "format": " {percentage}%",
          "states": { "warning": 80, "critical": 95 },
          "tooltip": true,
          "tooltip-format": "{used}/{total} GiB"
        },

        "memory#swap": {
          "interval": 16,
          "format": "󰾵 {swapPercentage}%",
          "tooltip": true,
          "tooltip-format": "{swapUsed}/{swapTotal} GiB"
        },

        "network#info": {
          "interval": 2,
          "format": "󱘖  Offline",
          "format-wifi": "{icon} {bandwidthDownBits}",
          "format-ethernet": "󰈀 {bandwidthDownBits}",
          "min-length": 11,
          "tooltip": true,
          "tooltip-format-wifi": "{ifname}\n{essid}\n{signalStrength}% \n{frequency} GHz\n󰇚 {bandwidthDownBits}\n󰕒 {bandwidthUpBits}",
          "tooltip-format-ethernet": "{ifname}\n󰇚 {bandwidthDownBits}\n󰕒 {bandwidthUpBits}",
          "format-icons": ["󰤫", "󰤟", "󰤢", "󰤥", "󰤨"],
          "states": { "normal": 25 }
        },

        "hyprland/submap": {
          "always-on": true,
          "default-submap": "",
          "format": "{}",
          "tooltip": false
        },

        "hyprland/window": {
          "format": "{title}",
          "max-length": 48,
          "tooltip": false,
          "icon": true,
          "icon-size": 18
        },

        "hyprland/workspaces": {
          "disable-scroll-wraparound": true,
          "smooth-scrolling-threshold": 4,
          "enable-bar-scroll": true,
          "format": "{icon}",
          "show-special": true,
          "special-visible-only": false,
          "format-icons": {
            "magic": "",
            "zellij": "",
            "10": "󰊴",
            "lock": ""
          }
        },

        "pulseaudio#output": {
          "format": "{icon} {volume}%",
          "format-muted": "󰝟 {volume}%",
          "format-bluetooth": " {icon} {volume}%",
          "format-bluetooth-muted": " 󰝟 {volume}%",
          "format-icons": {
            "headphone": "󰋋",
            "hands-free": "󰋎",
            "headset": "󰋎",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["󰕿", "󰖀", "󰕾"]
          },
          "on-click":       "pactl set-sink-mute @DEFAULT_SINK@ toggle",
          "on-click-right": "pwvucontrol",
          "on-scroll-up":   "pactl set-sink-volume @DEFAULT_SINK@ +2%",
          "on-scroll-down": "pactl set-sink-volume @DEFAULT_SINK@ -2%",
          "tooltip": true,
          "scroll-step": 4
        },

        "pulseaudio#input": {
          "format": "{format_source}",
          "format-source": "󰍬 {volume}%",
          "format-source-muted": "󰍭 {volume}%",
          "on-click":       "pactl set-source-mute @DEFAULT_SOURCE@ toggle",
          "on-click-right": "pwvucontrol",
          "on-scroll-up":   "pactl set-source-volume @DEFAULT_SOURCE@ +2%",
          "on-scroll-down": "pactl set-source-volume @DEFAULT_SOURCE@ -2%",
          "max-volume": "100",
          "tooltip-format": "{source_desc}",
          "scroll-step": 4
        },

        "pulseaudio/slider": {
          "min": 0,
          "max": 100,
          "orientation": "horizontal"
        },

        "group/vol-out": {
          "orientation": "horizontal",
          "drawer": {
            "transition-duration": 300,
            "children-class": "vol-slider-child",
            "transition-left-to-right": false
          },
          "modules": ["pulseaudio#output", "pulseaudio/slider"]
        },

        "temperature": {
          "critical-threshold": 90,
          "interval": 4,
          "format": "{icon} {temperatureC}°",
          "format-icons": ["", "", "", "", ""],
          "tooltip": false
        },

        "tray": {
          "icon-size": 18,
          "spacing": 8
        },

        "custom/spacer1": { "format": "", "tooltip": false },
        "custom/spacer2": { "format": "", "tooltip": false },
        "custom/spacer3": { "format": "", "tooltip": false },
        "custom/spacer4": { "format": "", "tooltip": false },
        "custom/spacer5": { "format": "", "tooltip": false },
        "custom/spacer6": { "format": "", "tooltip": false },

        "custom/trayicon": {
          "format": "󱄅 ",
          "tooltip": false
        }
      },

      {
        // INDICATOR BAR — overlaid battery charge line (top + bottom border blinks)
        "layer": "top",
        "position": "top",
        "name": "indicator",
        "passthrough": true,
        "reload_style_on_change": true,

        "height": 30,
        "margin-top": -29,
        "margin-right": 24,

        "modules-right": ["custom/batteryindicator"],

        "custom/batteryindicator": {
          "interval": 4,
          "return-type": "json",
          "tooltip": false,
          "format": " ",
          "exec": "~/.config/waybar/bat-pp.sh bar"
        }
      }
    ]
  '';

  # ── Style ────────────────────────────────────────────────────────────────────

  xdg.configFile."waybar/style.css".text = ''
    /* Catppuccin Mocha — adapted from Jan-Aarela's Mocha-Power */

    @define-color background1  rgba(32, 32, 48, 1);
    @define-color background2  rgba(21, 21, 32, 1);
    @define-color sepepator    #313244;
    @define-color warning      #f38ba8;
    @define-color caution      #45475a;
    @define-color performance  #f5c2e7;
    @define-color audio        #cba6f7;
    @define-color misc         #94e2d5;
    @define-color date         #a6e3a1;
    @define-color work         #b4befe;
    @define-color window       #b4befe;
    @define-color resize       #eba0ac;
    @define-color process      #89b4fa;
    @define-color text         #000000;

    /* ── Reset ── */
    * {
      border: none;
      border-radius: 0;
      min-height: 0;
      margin: 0;
      padding: 0;
      box-shadow: none;
      text-shadow: none;
    }

    /* ── Keyframes ── */
    @keyframes blink-urgent-workspace {
      to { color: @warning; }
    }
    @keyframes blink-critical-text {
      to { color: @sepepator; }
    }
    @keyframes blink-modifier-text {
      to { color: @sepepator; }
    }
    @keyframes blink-special-workspace {
      to { color: @window; }
    }

    /* ── Main bar ── */
    #waybar.main {
      background: @background2;
      font-family: "JetBrainsMono Nerd Font propo";
      font-size: 12pt;
      font-weight: 600;
      color: @text;
      border-radius: 6pt;
    }

    #waybar.main button {
      font-family: "JetBrainsMono Nerd Font propo";
      font-size: 12pt;
      font-weight: 600;
      color: @text;
    }

    /* ── Module padding defaults ── */
    #waybar.main #custom-weather,
    #waybar.main #custom-battery,
    #waybar.main #keyboard-state,
    #waybar.main #network,
    #waybar.main #battery,
    #waybar.main #backlight,
    #waybar.main #clock,
    #waybar.main #cpu,
    #waybar.main #language,
    #waybar.main #memory.swap,
    #waybar.main #memory.ram,
    #waybar.main #submap,
    #waybar.main #pulseaudio,
    #waybar.main #temperature,
    #waybar.main #traym,
    #waybar.main #window,
    #waybar.main #disk {
      padding-left:  8pt;
      padding-right: 8pt;
    }

    #waybar.main #custom-weather {
      padding-right: 8pt;
    }

    /* ── Module colours ── */
    #waybar.main #cpu,
    #waybar.main #temperature,
    #waybar.main #memory.ram,
    #waybar.main #memory.swap,
    #waybar.main #disk,
    #waybar.main #network {
      color: @performance;
      background: @background1;
    }

    #waybar.main #pulseaudio {
      color: @audio;
      background: @background2;
    }

    /* ── Volume slider drawer ── */
    #waybar.main #vol-out {
      background: @background2;
      padding: 0;
    }

    #waybar.main #pulseaudio-slider {
      padding-left:  4px;
      padding-right: 4px;
      background: @background2;
    }

    #waybar.main #pulseaudio-slider trough {
      min-width: 80px;
      min-height: 3px;
      border-radius: 4px;
      background: @sepepator;
    }

    #waybar.main #pulseaudio-slider highlight {
      background: @audio;
      border-radius: 4px;
    }

    #waybar.main #pulseaudio-slider slider {
      min-height: 0;
      min-width:  0;
      opacity:    0;
      background: transparent;
      padding:    0;
      margin:     0;
    }

    #waybar.main #language,
    #waybar.main #backlight,
    #waybar.main #battery,
    #waybar.main #custom-battery {
      color: @misc;
      background: @background1;
    }

    #waybar.main #custom-weather,
    #waybar.main #clock {
      color: @date;
      background: @background2;
    }

    #waybar.main #clock {
      border-radius: 0pt 6pt 6pt 0pt;
    }

    #waybar.main #window {
      color: @window;
      box-shadow: none;
      font-style: italic;
    }

    #waybar.main #network.info {
      padding-right: 10px;
      padding-left:  10px;
      color: @caution;
    }

    #waybar.main #network.info.wifi.normal,
    #waybar.main #network.info.ethernet {
      color: @performance;
      padding-right: 15px;
    }

    #waybar.main #network.info.wifi {
      color: @warning;
      padding-right: 15px;
    }

    /* ── Submap ── */
    #waybar.main #submap {
      color: @resize;
      animation-iteration-count: infinite;
      animation-direction: alternate;
      animation-name: blink-modifier-text;
      animation-duration: 1s;
      animation-timing-function: steps(15);
      box-shadow: none;
    }

    /* ── Criticals ── */
    #waybar.main #memory.swap.critical,
    #waybar.main #memory.ram.critical,
    #waybar.main #cpu.critical,
    #waybar.main #temperature.critical {
      color: @warning;
      animation-iteration-count: infinite;
      animation-direction: alternate;
      animation-name: blink-critical-text;
      animation-duration: 1s;
      animation-timing-function: steps(15);
    }

    #waybar.main #workspaces button.urgent,
    #waybar.main #workspaces button.special.urgent {
      transition: all 0s ease;
      background-image: linear-gradient(
        -63.435deg,
        transparent 25%,
        @background2 25%,
        @background2 75%,
        transparent 75%
      );
      animation-iteration-count: infinite;
      animation-direction: alternate;
      animation-name: blink-urgent-workspace;
      animation-duration: 1s;
      animation-timing-function: steps(15);
    }

    /* ── Warnings ── */
    #waybar.main #pulseaudio.output.muted,
    #waybar.main #pulseaudio.input.source-muted {
      color: @sepepator;
    }

    #waybar.main #custom-battery.warning,
    #waybar.main #custom-battery.critical {
      color: @warning;
    }

    /* ── Battery charging animation (disabled) ── */
    #waybar.main #custom-battery.charging {
      color: @misc;
    }

    /* ── Workspaces ── */
    #waybar.main #workspaces {
      padding-left:   20px;
      padding-right:  4px;
      margin-top:    -6px;
      margin-bottom: -6px;
      background-image: linear-gradient(
        -243.435deg,
        @background2 17px,
        @sepepator   17px,
        @sepepator   21px,
        transparent  21px,
        transparent  calc(100% - 22px),
        @sepepator   calc(100% - 22px),
        @sepepator   calc(100% - 18px),
        transparent  calc(100% - 18px)
      );
    }

    #waybar.main #workspaces button {
      color: #45475a;
      background: transparent;
      border: 1.5px solid transparent;
      transition: all 0.25s ease;
      padding-right: 16px;
      padding-left:  16px;
      font-style: italic;
      margin-left: -17px;
      padding-top:    6px;
      padding-bottom: 6px;
      background-image: linear-gradient(
        -63.435deg,
        transparent  25%,
        @background2 25%,
        @background2 75%,
        transparent  75%
      );
    }

    #waybar.main #workspaces button.visible {
      color: @text;
      background-image: linear-gradient(
        -63.435deg,
        transparent 25%,
        @caution    25%,
        @caution    75%,
        transparent 75%
      );
    }

    #waybar.main #workspaces button.active {
      color: @window;
      background-image: linear-gradient(
        -63.435deg,
        transparent  24%,
        @sepepator   24%,
        @sepepator   28%,
        @background1 28%,
        @background1 73%,
        @sepepator   73%,
        @sepepator   76%,
        transparent  76%
      );
    }

    #waybar.main #workspaces button:hover {
      color: @window;
    }

    #waybar.main #workspaces button.special.active {
      transition: all 0s ease;
      border: 1.5px solid transparent;
      color: @sepepator;
      animation-iteration-count: infinite;
      animation-direction: alternate;
      animation-name: blink-special-workspace;
      animation-duration: 1s;
      animation-timing-function: steps(15);
    }

    /* ── Diagonal spacers ── */
    #waybar.main #custom-spacer1,
    #waybar.main #custom-spacer2,
    #waybar.main #custom-spacer3,
    #waybar.main #custom-spacer4,
    #waybar.main #custom-spacer5,
    #waybar.main #custom-spacer6 {
      font-size: 16pt;
      font-weight: bold;
      color: transparent;
      padding-left:   4px;
      padding-right:  4px;
      margin-bottom: -4px;
      margin-top:    -4px;
    }

    #waybar.main #custom-spacer1 {
      background-image: linear-gradient(
        63.435deg,
        transparent  47.5%,
        @sepepator   47.6%,
        @sepepator   52.4%,
        @background1 52.5%
      );
    }

    #waybar.main #custom-spacer2 {
      background-image: linear-gradient(
        63.435deg,
        @background1 47.5%,
        @sepepator   47.6%,
        @sepepator   52.4%,
        @background2 52.5%
      );
    }

    #waybar.main #custom-spacer3 {
      background-image: linear-gradient(
        63.435deg,
        @background2 47.5%,
        @sepepator   47.6%,
        @sepepator   52.4%,
        @background1 52.5%
      );
    }

    #waybar.main #custom-spacer4 {
      background-image: linear-gradient(
        63.435deg,
        @background1 47.5%,
        @sepepator   47.6%,
        @sepepator   52.4%,
        @background2 52.5%
      );
    }

    #waybar.main #custom-spacer5 {
      background-image: linear-gradient(
        -63.435deg,
        transparent 47.5%,
        @sepepator  47.6%,
        @sepepator  52.4%,
        transparent 52.5%
      );
    }

    #waybar.main #custom-spacer6 {
      background-image: linear-gradient(
        -63.435deg,
        transparent 47.5%,
        @sepepator  47.6%,
        @sepepator  52.4%,
        transparent 52.5%
      );
    }

    /* ── Tray icon (NixOS snowflake) ── */
    #waybar.main #custom-trayicon {
      font-size: 11pt;
      color: @misc;
      background: transparent;
      padding-left:  2pt;
      padding-right: 0pt;
    }

    /* ── Tooltip ── */
    tooltip {
      background: @background2;
      border: 3px solid @caution;
      border-radius: 8px;
      font-weight: 500;
      font-family: "JetBrains Mono Nerd Font";
    }

    #waybar.main #tray menu {
      background: @background2;
      border: 3px solid @caution;
      border-radius: 8px;
    }

    /* ── Indicator bar keyframes ── */
    @keyframes blink-critical-battery {
      to {
        border-color: @warning;
        box-shadow:
          inset 0px  3px 4px -5px @warning,
          inset 0px -3px 4px -5px @warning;
      }
    }
    @keyframes blink-warning-battery {
      to {
        border-color: @warning;
        box-shadow:
          inset 0px  3px 4px -5px @warning,
          inset 0px -3px 4px -5px @warning;
      }
    }
    @keyframes blink-discharging-battery {
      to {
        border-color: @warning;
        box-shadow:
          inset 0px  3px 4px -5px @warning,
          inset 0px -3px 4px -5px @warning;
      }
    }
    @keyframes blink-charging-battery {
      to {
        border-color: @misc;
        box-shadow:
          inset 0px  3px 4px -5px @misc,
          inset 0px -3px 4px -5px @misc;
      }
    }
    @keyframes blink-full-battery {
      to {
        border-color: @misc;
        box-shadow:
          inset 0px  3px 4px -5px @misc,
          inset 0px -3px 4px -5px @misc;
      }
    }

    /* ── Indicator bar ── */
    #waybar.indicator {
      font-size: 10px;
      color: rgba(0, 0, 0, 0);
      background: rgba(0, 0, 0, 0);
    }

    #waybar.indicator #custom-batteryindicator {
      border: 2.5px solid @sepepator;
      background: transparent;
      box-shadow:
        inset 0px  4px 4px -5px rgba(0, 0, 0, 0.5),
        inset 0px -4px 4px -5px rgba(0, 0, 0, 0.5);
      border-radius: 7px;
      /* (2560/1) - 0 margin-left - 24 margin-right - 2*2.5 border - (10/2) font */
      padding-left: 2526px;
    }

    #waybar.indicator #custom-batteryindicator.critical {
      animation-iteration-count: infinite;
      animation-direction: alternate;
      animation-name: blink-critical-battery;
      animation-duration: 1s;
      animation-timing-function: steps(15);
    }

    #waybar.indicator #custom-batteryindicator.warning {
      animation-iteration-count: 4;
      animation-direction: alternate;
      animation-name: blink-warning-battery;
      animation-duration: 0.2s;
      animation-timing-function: steps(15);
    }

    #waybar.indicator #custom-batteryindicator.discharging {
      animation-iteration-count: 2;
      animation-direction: alternate;
      animation-name: blink-discharging-battery;
      animation-duration: 0.3s;
      animation-timing-function: steps(15);
    }

    #waybar.indicator #custom-batteryindicator.charging {
      /* charging animation disabled */
    }

    #waybar.indicator #custom-batteryindicator.full {
      animation-iteration-count: 4;
      animation-direction: alternate;
      animation-name: blink-full-battery;
      animation-duration: 0.2s;
      animation-timing-function: steps(15);
    }
  '';

  # ── Battery + power-profile script ──────────────────────────────────────────
  # Reads /sys/class/power_supply/BAT0.
  # On-click toggles power-profiles-daemon profile (performance→balanced→power-saver).
  # Falls back gracefully if power-profiles-daemon is not enabled.

  xdg.configFile."waybar/bat-pp.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      BAT="/sys/class/power_supply/BAT1"

      capacity() { cat "$BAT/capacity" 2>/dev/null || echo 50; }
      bstatus()  { cat "$BAT/status"   2>/dev/null || echo "Unknown"; }

      bat_class() {
        local cap; cap=$(capacity)
        local sta; sta=$(bstatus)
        if   [[ "$sta" == "Full" ]];     then echo "full"
        elif [[ "$sta" == "Charging" ]]; then echo "charging"
        elif [[ "$cap" -le 10 ]];        then echo "critical"
        elif [[ "$cap" -le 25 ]];        then echo "warning"
        else                                  echo "discharging"
        fi
      }

      bat_icon() {
        local cap; cap=$(capacity)
        local sta; sta=$(bstatus)
        case "$sta" in
          Charging) echo "󰂄" ;;
          Full)     echo "󰁹" ;;
          *)
            if   [[ "$cap" -le 10 ]]; then echo "󰁺"
            elif [[ "$cap" -le 25 ]]; then echo "󰁻"
            elif [[ "$cap" -le 50 ]]; then echo "󰁽"
            elif [[ "$cap" -le 75 ]]; then echo "󰁿"
            else                           echo "󰂁"
            fi ;;
        esac
      }

      profile_info() {
        local p; p=$(powerprofilesctl get 2>/dev/null || echo "balanced")
        case "$p" in
          performance) echo "󰓅 $p" ;;
          power-saver) echo "󰾆 $p" ;;
          *)           echo "󰗑 $p" ;;
        esac
      }

      case "$1" in
        bar)
          printf '{"text": " ", "class": "%s"}\n' "$(bat_class)"
          ;;
        toggle)
          current=$(powerprofilesctl get 2>/dev/null || echo "balanced")
          case "$current" in
            performance) powerprofilesctl set balanced    ;;
            balanced)    powerprofilesctl set power-saver ;;
            *)           powerprofilesctl set performance ;;
          esac
          ;;
        *)
          cap=$(capacity)
          icon=$(bat_icon)
          prof=$(profile_info)
          cl=$(bat_class)
          alt="$icon $cap% | $prof"
          printf '{"text":"%s %s","alt":"%s","tooltip":"%s","class":"%s"}\n' \
            "$icon" "$cap" "$alt" "$alt" "$cl"
          ;;
      esac
    '';
  };
}

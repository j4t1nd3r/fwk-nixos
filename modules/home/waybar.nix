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
#   - Indicator bar padding: (2560/1) - 5 - 5 - 2*2.5 - (10/2) = 2540px

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

        "margin-top": 5,
        "margin-left": 5,
        "margin-right": 5,

        "modules-left": [
          "group/traym",
          "hyprland/workspaces",
          "hyprland/submap",
          "custom/media"
        ],

        "modules-center": [
          "custom/media-prev",
          "custom/media-play",
          "custom/media-next"
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
        },

        "custom/media": {
          "interval": 2,
          "return-type": "json",
          "tooltip": true,
          "exec": "playerctl metadata --format '{\"text\":\"{{trunc(artist,20)}} — {{trunc(title,30)}}\",\"tooltip\":\"{{artist}} — {{title}}\",\"class\":\"playing\"}' 2>/dev/null || echo '{\"text\":\"\",\"class\":\"stopped\"}'"
        },

        "custom/media-prev": {
          "format": "⏮",
          "tooltip": false,
          "on-click": "playerctl previous",
          "exec": "playerctl status 2>/dev/null | grep -q 'Playing\\|Paused' && echo '{\"text\":\"⏮\",\"class\":\"active\"}' || echo '{\"text\":\"\",\"class\":\"stopped\"}'",
          "return-type": "json",
          "interval": 2
        },

        "custom/media-play": {
          "format": "{}",
          "tooltip": false,
          "on-click": "playerctl play-pause",
          "exec": "status=$(playerctl status 2>/dev/null); if [ \"$status\" = 'Playing' ]; then echo '{\"text\":\"⏸\",\"class\":\"playing\"}'; elif [ \"$status\" = 'Paused' ]; then echo '{\"text\":\"▶\",\"class\":\"paused\"}'; else echo '{\"text\":\"\",\"class\":\"stopped\"}'; fi",
          "return-type": "json",
          "interval": 2
        },

        "custom/media-next": {
          "format": "⏭",
          "tooltip": false,
          "on-click": "playerctl next",
          "exec": "playerctl status 2>/dev/null | grep -q 'Playing\\|Paused' && echo '{\"text\":\"⏭\",\"class\":\"active\"}' || echo '{\"text\":\"\",\"class\":\"stopped\"}'",
          "return-type": "json",
          "interval": 2
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
        "margin-left": 5,
        "margin-right": 5,

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
}


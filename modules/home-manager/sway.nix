{ lib, config, pkgs, inputs, ... }:

let
  cfg = config.t.sway;
  modifier = "Mod4";
# TODO: make this arch independant
  hyprmag = inputs.hyprmag.packages."x86_64-linux".hyprmag;
in
{
  options = {
    t.sway = lib.mkEnableOption "enable sway module";
  };

  config = lib.mkIf cfg {
    home.packages = [
      pkgs.wofi
      pkgs.swaybg
      pkgs.acpi
    ];

    programs.kitty.enable = true;
    catppuccin.pointerCursor.enable = false;

    home.pointerCursor =  {
      gtk.enable = true;
      package = pkgs.posy-cursors;
      name = "Posy_Cursor_Black";
      size = 22;
    };

    wayland.windowManager.sway = {
      enable = true;
      catppuccin.enable = true;
      config = {
        modifier = modifier;
        terminal = "kitty";
        bars = [];
        colors = {
          background = "$base";
          focused = {
            background = "$mauve";
            border = "$mauve";
            childBorder = "$mauve";
            indicator = "$mauve";
            text = "$crust";
          };
          unfocused = {
            background = "$surface1";
            border = "$surface1";
            childBorder = "$surface1";
            indicator = "$surface1";
            text = "$text";
          };
          focusedInactive = {
            background = "$surface2";
            border = "$surface2";
            childBorder = "$surface2";
            indicator = "$surface2";
            text = "$text";
          };
        };
        gaps = {
            inner = 4;
        };
        startup = [
          {command = "waybar";}
          {command = "swaybg --color 11111b --mode center --image /etc/nixos/kitppuccin.png";}
          {command = "sleep 5 && systemctl --user start kanshi.service";}
          {command = "sleep 10 && ${pkgs.polkit_gnome
}/libexec/polkit-gnome-authentication-agent-1";}
          {command = "sleep 30 && ${pkgs._1password-gui}/bin/1password --silent";}
          {command = "sleep 30 && ${pkgs.networkmanagerapplet}/bin/nm-applet";} 
        ];

        input."2362:628:PIXA3854:00_093A:0274_Touchpad" = {
          natural_scroll = "enabled";
          scroll_factor = "0.4";
        };

        keybindings = lib.mkOptionDefault {
          "${modifier}+d" = "exec ${pkgs.fuzzel}/bin/fuzzel";

          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl --device intel_backlight --min-value=1 set 5%-";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl --device intel_backlight set 5%+";

          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +10%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -10%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

          "Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot savecopy anything";
          "${modifier}+m" = "exec ${hyprmag}/bin/hyprmag";
        };
      };
    };

    services.kanshi = {
      enable = true;
      settings = [
        {
          profile.name = "tricky-desktop";
          profile.exec = [ 
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to DP-2"
            "${pkgs.sway}/bin/swaymsg workspace 2, move workspace to DP-3"
          ];
          profile.outputs = [
            { criteria = "DP-2"; position = "0,600";scale = 1.25;   }
            { criteria = "DP-3"; transform = "90"; position = "3840,0";scale = 1.25;  }
          ];
        }
        {
          profile.name = "tricky-fw-default";
          profile.exec = [
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to eDP-1"
          ];
          profile.outputs = [
            { criteria = "eDP-1"; scale = 1.25; }
          ];
        }
        {
          profile.name = "tricky-fw-desk";
          profile.exec = [
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to DP-3"
            "${pkgs.sway}/bin/swaymsg workspace 2, move workspace to DP-6"
          ];
          profile.outputs = [
            { criteria = "eDP-1"; status = "disable"; }
            { criteria = "DP-3"; position = "0,600"; scale = 1.25;  }
            { criteria = "DP-6"; transform = "90"; position = "3840,0"; scale = 1.25;  }
          ];
        }
        {
          profile.name = "tricky-fw-desk2";
          profile.exec = [
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to DP-3"
            "${pkgs.sway}/bin/swaymsg workspace 2, move workspace to DP-5"
          ];
          profile.outputs = [
            { criteria = "eDP-1"; status = "disable"; }
            { criteria = "DP-3"; position = "0,600"; scale = 1.25;  }
            { criteria = "DP-5"; transform = "90"; position = "3840,0"; scale = 1.25; }
          ];
        }
      ];
    };

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          name = "mainBar";
          layer = "top";
          position = "top";

          modules-left = [ "sway/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ "tray" "group/volume" "group/backlight" "power-profiles-daemon" "battery" ];

          "group/volume" = {
            orientation = "horizontal";
            drawer = {
              transition-duration = 200;
            };
            modules = [ "pulseaudio" "pulseaudio/slider" ];
          };

          pulseaudio = {
             format = "{icon}   {volume}%";
             format-icons = {
               default = ["" ""];
             };
          };

          "group/backlight" = {
            orientation = "horizontal";
            drawer = {
              transition-duration = 200;
            };
            modules = [ "backlight" "backlight/slider" ];
          };

          backlight = {
            format = "{icon}   {percent}%";
            format-icons = ["" ""];
          };

          power-profiles-daemon = {
            format = "{icon}";
            tooltip-format = "Power profile: {profile}\nDriver: {driver}";
            tooltip = true;
            format-icons = {
              default = "";
              performance = "";
              balanced = "";
              power-saver = "";
            };
          };

          battery = {
            format = "{icon}   {capacity}%";
            format-icons = ["" "" "" "" ""];
          };
        };
      };
      style = ''
        * {
          font-size: 0.75rem;
          font-weight: 500;
        }

        #waybar {
          background: none;
          color: #cad3f5;
        }

        .modules-right > * > * {
          margin: 0 0.5rem;
        }

        .modules-left .text-button {
          padding: 0 0.65rem;
          border-radius: 100%;
        }

        #workspaces .focused {
          background-color: #ca9ee6;
          color: #292c3c;
        }

        trough {
          min-height: 10px;
          min-width: 80px;
        }
      '';
      catppuccin.enable = false;
    };
  };
}

{ lib, config, pkgs, ... }:

let
  cfg = config.t.sway;
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
      pkgs.lxqt.lxqt-policykit
    ];

    programs.kitty.enable = true;

    wayland.windowManager.sway = {
      enable = true;
      catppuccin.enable = true;
      config = {
        modifier = "Mod4";
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
            inner = 8;
        };
        startup = [
          {command = "waybar";}
          {command = "swaybg --color 11111b --mode center --image /etc/nixos/kitppuccin.png";}
          {command = "sleep 5 && systemctl --user start kanshi.service";}
          {command = "sleep 10 && ${pkgs.lxqt.lxqt-policykit
}/bin/lxqt-policykit-agent";}
          {command = "sleep 30 && ${pkgs._1password-gui}/bin/1password --silent";}
          {command = "sleep 30 && ${pkgs.networkmanagerapplet}/bin/nm-applet";} 
        ];

        input."2362:628:PIXA3854:00_093A:0274_Touchpad" = {
          natural_scroll = "enabled";
          scroll_factor = "0.2";
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
            { criteria = "DP-2"; position = "0,600";  }
            { criteria = "DP-3"; transform = "90"; position = "3840,0"; }
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
            { criteria = "DP-3"; position = "0,600";  }
            { criteria = "DP-6"; transform = "90"; position = "3840,0"; }
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
          modules-right = [ "tray" "group/volume" "group/backlight" "battery" ];

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

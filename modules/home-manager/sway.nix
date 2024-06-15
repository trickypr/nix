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
    ];

    wayland.windowManager.sway = {
      enable = true;
      catppuccin.enable = true;
      config = rec {
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
          {command = "sleep 5; systemctl --user start kanshi.service";}
          {command = "sleep 30; 1password --silent";}
        ];
      };
    };

    services.kanshi = {
      enable = true;
      settings = [
        {
          profile.name = "desktop";
          profile.exec = [ 
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to DP-2"
            "${pkgs.sway}/bin/swaymsg workspace 2, move workspace to DP-3"
          ];
          profile.outputs = [
            { criteria = "DP-2"; position = "0,600";  }
            { criteria = "DP-3"; transform = "90"; position = "3840,0"; }
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
          modules-right = [ "tray" "pulseaudio" "backlight" "battery" ];

          "hyprland/workspaces" = {
            all-outputs = true;
            show-special = true;
          };
        };
      };
      style = ''
        * {
          font-family: "FiraCodeNerdFont";
        }

        #waybar {
            background: none;
        }

        .modules-right {
            padding: 0 12px;
        }

        #workspaces .focused {
          background-color: #ca9ee6;
          color: #292c3c;
        }
      '';
      catppuccin.enable = false;
    };
  };
}

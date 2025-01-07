{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.t.sway;
  modifier = "Mod4";
  # TODO: make this arch independant
  hyprmag = inputs.hyprmag.packages."x86_64-linux".hyprmag;

  run-without-safeeeyes = pkgs.writeShellScriptBin "run-without-safeeeyes" ''
    #!${pkgs.zsh}/bin/zsh
    current_window=$(swaymsg -t get_tree | grep -A 45 '"focused": true' | egrep 'app_id|class' | cut -d \" -f 4 | grep .)

    if [[ "$current_window" != "safeeyes" ]]; then
       swaymsg "$@"
    fi
  '';

  rws = "exec ${run-without-safeeeyes}/bin/run-without-safeeeyes";
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

    programs.kitty = {
      enable = true;
      settings = {
        font_family = "FiraCode Nerd Font";
        font_size = "13.75";

        linux_display_server = "wayland";
      };
    };
    catppuccin.pointerCursor.enable = false;

    home.pointerCursor = {
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
        terminal = "${pkgs.kitty}/bin/kitty";
        bars = [ ];
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
          { command = "waybar"; }
          { command = "swaybg --color 11111b --mode center --image /etc/nixos/kitppuccin.png"; }
          { command = "sleep 5 && systemctl --user start kanshi.service"; }
          {
            command = "sleep 6 && ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          }
          { command = "sleep 10 && ${pkgs._1password-gui}/bin/1password --silent"; }
          { command = "sleep 10 && ${pkgs.networkmanagerapplet}/bin/nm-applet"; }
          { command = "sleep 10 && ${pkgs.blueman}/bin/blueman"; }
        ];

        input."2362:628:PIXA3854:00_093A:0274_Touchpad" = {
          natural_scroll = "enabled";
          scroll_factor = "0.4";
        };

        keybindings = lib.mkOptionDefault {
          "${modifier}+Shift+q" = "${rws} kill";

          "${modifier}+Shift+space" = "${rws} floating toggle";
          "${modifier}+space" = "${rws} focus mode_toggle";

          "${modifier}+1" = "${rws} workspace number 1";
          "${modifier}+2" = "${rws} workspace number 2";
          "${modifier}+3" = "${rws} workspace number 3";
          "${modifier}+4" = "${rws} workspace number 4";
          "${modifier}+5" = "${rws} workspace number 5";
          "${modifier}+6" = "${rws} workspace number 6";
          "${modifier}+7" = "${rws} workspace number 7";
          "${modifier}+8" = "${rws} workspace number 8";
          "${modifier}+9" = "${rws} workspace number 9";
          "${modifier}+0" = "${rws} workspace number 10";

          "${modifier}+Shift+1" = "${rws} move container to workspace number 1";
          "${modifier}+Shift+2" = "${rws} move container to workspace number 2";
          "${modifier}+Shift+3" = "${rws} move container to workspace number 3";
          "${modifier}+Shift+4" = "${rws} move container to workspace number 4";
          "${modifier}+Shift+5" = "${rws} move container to workspace number 5";
          "${modifier}+Shift+6" = "${rws} move container to workspace number 6";
          "${modifier}+Shift+7" = "${rws} move container to workspace number 7";
          "${modifier}+Shift+8" = "${rws} move container to workspace number 8";
          "${modifier}+Shift+9" = "${rws} move container to workspace number 9";
          "${modifier}+Shift+0" = "${rws} move container to workspace number 10";

          "${modifier}+d" = "exec ${pkgs.fuzzel}/bin/fuzzel";
          "${modifier}+SHIFT+d" = "exec ${pkgs.fuzzel}/bin/fuzzel";

          "XF86MonBrightnessDown" =
            "exec ${pkgs.brightnessctl}/bin/brightnessctl --device intel_backlight --min-value=1 set 5%-";
          "XF86MonBrightnessUp" =
            "exec ${pkgs.brightnessctl}/bin/brightnessctl --device intel_backlight set 5%+";

          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +10%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -10%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

          "Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot savecopy anything";
          "Shift+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot savecopy active";
          "${modifier}+m" = "exec ${hyprmag}/bin/hyprmag";
        };
      };
    };

    home.activation.kanshi = lib.hm.dag.entryAfter [ "sway" "writeBoundary" ] ''
      run ${pkgs.systemd}/bin/systemctl restart --user kanshi
    '';
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
            {
              criteria = "DP-2";
              position = "0,600";
              scale = 1.25;
            }
            {
              criteria = "DP-3";
              transform = "90";
              position = "3840,0";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "tricky-desktop2";
          profile.exec = [
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to DP-1"
            "${pkgs.sway}/bin/swaymsg workspace 2, move workspace to DP-3"
          ];
          profile.outputs = [
            {
              criteria = "DP-1";
              position = "0,600";
              scale = 1.25;
            }
            {
              criteria = "DP-3";
              transform = "90";
              position = "3840,0";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "tricky-fw-default";
          profile.exec = [
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to eDP-1"
          ];
          profile.outputs = [
            {
              criteria = "eDP-1";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "tricky-fw-desk";
          profile.exec = [
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to DP-3"
            "${pkgs.sway}/bin/swaymsg workspace 2, move workspace to DP-6"
          ];
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "DP-3";
              position = "0,600";
              scale = 1.25;
            }
            {
              criteria = "DP-6";
              transform = "90";
              position = "3840,0";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "tricky-fw-desk2";
          profile.exec = [
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to DP-3"
            "${pkgs.sway}/bin/swaymsg workspace 2, move workspace to DP-5"
          ];
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "DP-3";
              position = "0,600";
              scale = 1.25;
            }
            {
              criteria = "DP-5";
              transform = "90";
              position = "3840,0";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "tricky-fw-desk3";
          profile.exec = [
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to DP-3"
            "${pkgs.sway}/bin/swaymsg workspace 2, move workspace to DP-1"
          ];
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "DP-3";
              position = "0,600";
              scale = 1.25;
            }
            {
              criteria = "DP-1";
              transform = "90";
              position = "3840,0";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "tricky-fw-desk4";
          profile.exec = [
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to DP-3"
            "${pkgs.sway}/bin/swaymsg workspace 2, move workspace to DP-2"
          ];
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "DP-3";
              position = "0,600";
              scale = 1.25;
            }
            {
              criteria = "DP-2";
              transform = "90";
              position = "3840,0";
              scale = 1.25;
            }
          ];
        }
      ];
    };

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
    };

    home.file.".config/rofi/selector.rasi".text = ''
      configuration {
        modi: "drun";
        show-icon: true;
      }
    '';

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          name = "mainBar";
          layer = "top";
          position = "top";

          modules-left = [ "sway/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [
            "tray"
            "group/volume"
            "group/backlight"
            "power-profiles-daemon"
            "battery"
          ];

          "group/volume" = {
            orientation = "horizontal";
            drawer = {
              transition-duration = 200;
            };
            modules = [
              "pulseaudio"
              "pulseaudio/slider"
            ];
          };

          pulseaudio = {
            format = "{icon}   {volume}%";
            format-icons = {
              default = [
                ""
                ""
              ];
            };
          };

          "group/backlight" = {
            orientation = "horizontal";
            drawer = {
              transition-duration = 200;
            };
            modules = [
              "backlight"
              "backlight/slider"
            ];
          };

          backlight = {
            format = "{icon}   {percent}%";
            format-icons = [
              ""
              ""
            ];
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
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
          };
        };
      };
      style = ''
        * {
          font-size: 0.75rem;
          font-weight: 500;
          font-family: "FiraCode Nerd Font", sans-serif;
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

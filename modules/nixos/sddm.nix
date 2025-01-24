{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.t.dm;
in
{
  options = {
    t.dm.enable = lib.mkEnableOption "enable display manager module";
    t.dm.keyring = lib.mkEnableOption "enable gnome keyring";
    t.dm.sway = lib.mkEnableOption "install sway, please configure via home-manager";
    t.dm.sway-vnc = lib.mkEnableOption "run sway in headless mode";
  };

  config = lib.mkIf cfg.enable {
    # Setup SDDM
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.displayManager.sddm.package = lib.mkForce pkgs.kdePackages.sddm;

    # Keyring
    services.gnome.gnome-keyring.enable = cfg.keyring;
    security.pam.services.sddm.enableGnomeKeyring = cfg.keyring;

    # Sway appear in the list and it the default session
    programs.sway.enable = cfg.sway;
    services.displayManager.defaultSession = "sway";

    # kanshi systemd service
    systemd.user.services.kanshi = lib.mkIf cfg.sway {
      description = "kanshi daemon";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
      };
    };

    systemd.user.services.sway-vnc = lib.mkIf cfg.sway-vnc {
      description = "sway vnc daemon";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          export WLR_BACKENDS=headless
          export WLR_LIBINPUT_NO_DEVICES=1
          export WAYLAND_DISPLAY=wayland-1
          export XDG_RUNTIME_DIR=/tmp
          export XDG_SESSION_TYPE=wayland
          ${pkgs.sway} &
          ${pkgs.wayvnc} --output=HEADLESS-1
        '';
      };
    };
  };
}

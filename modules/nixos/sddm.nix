{ lib, config, pkgs, ... }:

let
  cfg = config.t.dm;
in
{
  options = {
    t.dm.enable = lib.mkEnableOption "enable display manager module";
    t.dm.keyring = lib.mkEnableOption "enable gnome keyring";
    t.dm.sway = lib.mkEnableOption "install sway, please configure via home-manager";
  };

  config = lib.mkIf cfg.enable {
    # Setup SDDM
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.displayManager.sddm.package = pkgs.kdePackages.sddm;

    # Keyring
    services.gnome.gnome-keyring.enable = cfg.keyring;
    security.pam.services.sddm.enableGnomeKeyring = cfg.keyring;

    # Sway appear in the list
    programs.sway.enable = cfg.sway;

    # kanshi systemd service
    systemd.user.services.kanshi = lib.mkIf cfg.sway {
      description = "kanshi daemon";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
      };
    };
  };
}

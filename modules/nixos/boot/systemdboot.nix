{ lib, config, ... }:

let
  cfg = config.t.systemd-boot;
in
{
  options = {
    t.systemd-boot = lib.mkEnableOption "enable systemd boot";
  };

  config = lib.mkIf cfg {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}

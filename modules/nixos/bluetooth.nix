{ lib, config, ... }:
let
  cfg = config.t.bluetooth;
in
{
  options = {
    t.bluetooth = lib.mkEnableOption "enable system-level bluetooth support";
  };

  config = lib.mkIf cfg {
    hardware.bluetooth.enable = true;
    # Report the battery life of bluetooth devices
    hardware.bluetooth.settings.General = {
      Experimental = true;
    };
  };
}

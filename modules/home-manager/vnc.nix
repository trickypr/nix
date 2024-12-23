{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.t.vnc;
in
{
  options = {
    t.vnc = lib.mkEnableOption "enable vnc server";
  };

  config = lib.mkIf cfg {
    home.packages = [
      pkgs.wayvnc
    ];

    xdg.configFile."wayvnc/config".source = ./wayvnc.conf;
  };
}

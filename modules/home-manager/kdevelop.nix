{ lib, config, pkgs, ... }:
let
  cfg = config.t.kdevelop;
in
{
  options = {
    t.kdevelop = {
      enable = lib.mkEnableOption "enable kdevelop support";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.libsForQt5.kdevelop
    ];
  };
}

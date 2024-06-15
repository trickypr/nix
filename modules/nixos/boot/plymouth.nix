{ lib, config, ... }:

let
  cfg = config.t.plymouth;
in
{
  options = {
    t.plymouth = lib.mkEnableOption "enable plymouth module";
  };

  config = lib.mkIf cfg {
    boot.plymouth.enable = true;
  };
}

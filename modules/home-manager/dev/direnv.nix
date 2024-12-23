{ lib, config, ... }:

let
  cfg = config.t.dev;
in
{
  options = {
    t.dev.direnv = lib.mkEnableOption "enable direnv module";
  };

  config = lib.mkIf cfg.direnv {
    programs.direnv.enable = true;
    programs.direnv.enableZshIntegration = true;
  };
}

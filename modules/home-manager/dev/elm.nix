{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.t.dev;
in
{
  options = {
    t.dev.elm = lib.mkEnableOption "enable elm dev tooling";
  };

  config = lib.mkIf cfg.elm {
    home.packages = [
      pkgs.elmPackages.elm
      pkgs.elmPackages.elm-format
    ];
  };
}

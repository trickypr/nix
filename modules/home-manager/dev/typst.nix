{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.t.dev.typst;
in
{
  options = {
    t.dev.typst = {
      enable = lib.mkEnableOption "enable typst support";
      nvim = lib.mkEnableOption "enable typst nvim support";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [
        pkgs.typst
      ]
      ++ lib.optionals cfg.nvim [
        pkgs.tinymist
      ];
  };
}

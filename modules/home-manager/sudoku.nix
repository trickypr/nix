{ lib, config, pkgs, ... }:

let
  cfg = config.t.sudoku;
in
{
  options = {
    t.sudoku = {
      comp2120 = lib.mkEnableOption "enable comp2120";
    };
  };

  config = {
    home.packages = lib.optionals cfg.comp2120 [
      pkgs.python3
      pkgs.gitkraken
    ];
  };
}

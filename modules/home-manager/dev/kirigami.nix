{ lib, config, pkgs, ... }:
let
  cfg = config.t.dev;
in
{
  options = {
    t.dev.kirigami = lib.mkEnableOption "enable kirigami dependancies";
  };

  config = lib.mkIf cfg.kirigami {
    home.packages = [
      pkgs.kdePackages.kirigami
      pkgs.kdePackages.qtdeclarative
      pkgs.cmake
    ];
  };
}

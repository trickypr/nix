{ lib, config, pkgs, ... }:

let
  cfg = config.t.dev;
in
{
  options = {
    t.dev.rust = lib.mkEnableOption "enable rust dev tooling";
  };

  config = lib.mkIf cfg.rust {
    home.packages = [
      pkgs.cargo
      pkgs.rustc
      pkgs.rustfmt
      pkgs.clippy
      pkgs.cargo-watch
    ];
  };
}


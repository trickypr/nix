{ lib, config, pkgs, ... }:

let
  cfg = config.t.dev;
in
{
  options = {
    t.dev.js = lib.mkEnableOption "enable javascript dev tooling";
  };

  config = lib.mkIf cfg.js {
    home.packages = [
      pkgs.vscode-langservers-extracted
      pkgs.nodePackages.typescript-language-server

      pkgs.nodejs_22
      pkgs.nodePackages.pnpm
      pkgs.typescript
      pkgs.prettierd
    ];
  };
}

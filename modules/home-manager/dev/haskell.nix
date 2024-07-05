{lib, config, pkgs, ...}:

let
  cfg = config.t.dev.haskell;
in
{
  options = {
    t.dev.haskell = {
      enable = lib.mkEnableOption "enable haskell language support";
      vscode = lib.mkEnableOption "enable vscode support for haskell languages";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.haskell.compiler.ghc94
    ];

    programs.vscode = lib.mkIf cfg.vscode {
      extensions = [
        pkgs.vscode-extensions.haskell.haskell { supportedGhcVersions = [ "94" ]; }
      ];
    };
  };
}

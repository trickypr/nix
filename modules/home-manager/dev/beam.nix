{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.t.dev.beam;
in
{
  options = {
    t.dev.beam = {
      enable = lib.mkEnableOption "enable beam language support";
      vscode = lib.mkEnableOption "enable vscode support for beam languages";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.elixir-ls
      pkgs.elixir
      pkgs.gleam
      pkgs.erlang_27
      pkgs.rebar3
      pkgs.inotify-tools
    ];

    programs.vscode = lib.mkIf cfg.vscode {
      extensions = [
        pkgs.vscode-extensions.elixir-lsp.vscode-elixir-ls
        pkgs.vscode-extensions.phoenixframework.phoenix
      ];
    };
  };
}

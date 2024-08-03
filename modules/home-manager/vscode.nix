{ lib, config, pkgs, ... }:
let
  cfg = config.t.vscode;
in
{
  options = {
    t.vscode.enable = lib.mkEnableOption "enable tricky's vscode";
    t.vscode.vim = lib.mkEnableOption "enable vim mode & mappings for vscode";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      mutableExtensionsDir  = false;
    
      extensions = [
        pkgs.vscode-extensions.catppuccin.catppuccin-vsc
        pkgs.vscode-extensions.catppuccin.catppuccin-vsc-icons
        pkgs.vscode-extensions.ms-vscode.cpptools-extension-pack
        pkgs.vscode-extensions.bbenoist.nix
      ] ++ lib.optionals cfg.vim [
        pkgs.vscode-extensions.vscodevim.vim
        pkgs.vscode-extensions.ms-vscode.cpptools
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        { name = "keyboard-quickfix"; publisher = "pascalsenn"; version = "0.0.6"; sha256 = "sha256-BK7ND6gtRVEitxaokJHmQ5rvSOgssVz+s9dktGQnY6M="; }
      ];

      userSettings = {
        "workbench.colorTheme" = "Catppuccin Latte";
        "workbench.iconTheme" = "catppuccin-latte";
      } // lib.optionalAttrs cfg.vim {
        "editor.minimap.enable" = false;
        "editor.lineNumbers" = "relative";
        "vim.leader" = "<space>";
        "vim.normalModeKeyBindings" = [
          {
            before = ["<leader>" "<space>"];
            commands = ["workbench.action.quickOpen"];
          }
          {
            before = ["<leader>" "c" "a"];
            commands = ["keyboard-quickfix.openQuickFix"];
          }
        ];
      };
    };
  };
}

{ lib, config, pkgs, ... }:

let
  cfg = config.t.nvim;
in
{
  options = {
    t.nvim.enable = lib.mkEnableOption "enable tricky's nvim";
    t.nvim.default = lib.mkEnableOption "set nvim as the default editor";
  };

  config = lib.mkIf cfg.enable {
    # Needed for LSPs to function
    t.dev = {
      beam = { enable = true; };
      js = true;
    };

    home.packages = [
      pkgs.lua-language-server
      pkgs.nil
      pkgs.elmPackages.elm-language-server
      pkgs.rust-analyzer
      pkgs.ltex-ls
      pkgs.templ
      pkgs.go
      pkgs.gopls
      # pkgs.python311Packages.python-lsp-server
      pkgs.pyright

      # clipboard support
      pkgs.wl-clipboard

      # needed by treesitter
      pkgs.clang
      pkgs.clang-tools
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = cfg.default;
      vimAlias = true;
      catppuccin.enable = false; # will overwrite my nvim config
    };

    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/modules/home-manager/nvim-conf";
      recursive = true;
    };
  };
}

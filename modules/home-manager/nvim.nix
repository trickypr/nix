{
  lib,
  config,
  pkgs,
  ...
}:

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
      beam = {
        enable = true;
      };
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
      pkgs.python311Packages.python-lsp-server
      pkgs.pyright
      pkgs.nodePackages_latest.svelte-language-server
      pkgs.prettierd
      pkgs.pylyzer
      pkgs.vhdl-ls

      # clipboard support
      pkgs.wl-clipboard

      # needed by treesitter
      pkgs.clang
      pkgs.clang-tools

      # formatters
      pkgs.stylua
      pkgs.nixfmt-rfc-style

      pkgs.bat
    ];

    # will overwrite my nvim config
    catppuccin.nvim.enable = false;
    programs.neovim = {
      enable = true;
      defaultEditor = cfg.default;
      vimAlias = true;
    };

    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/modules/home-manager/nvim-conf";
      recursive = true;
    };
  };
}

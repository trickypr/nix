{
  lib,
  config,
  pkgs,
  inputs,
  system,
  ...
}:

let
  cfg = config.t.nvim;
  emmet-helper = inputs.emmet-helper.packages."${system}".emmet-helper;
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

    home.packages = with pkgs; [
      lua-language-server
      nil
      elmPackages.elm-language-server
      rust-analyzer
      ltex-ls
      templ
      go
      gopls
      python311Packages.python-lsp-server
      pyright
      nodePackages_latest.svelte-language-server
      prettierd
      pylyzer
      vhdl-ls
      emmet-helper

      # clipboard support
      wl-clipboard

      # needed by treesitter
      clang
      clang-tools

      # formatters
      stylua
      nixfmt-rfc-style

      bat
      # Diff engine for code actions
      delta
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

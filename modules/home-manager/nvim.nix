{ lib, config, ... }:

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

    programs.neovim = {
      enable = true;
      defaultEditor = cfg.default;
      vimAlias = true;
      catppuccin.enable = false; # will overwrite my nvim config
    };

    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink ./nvim-conf;
      recursive = true;
    };
  };
}

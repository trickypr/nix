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
      jdt-language-server
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

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      # neovim integration
      extraConfig = ''
        # Smart pane switching with awareness of Vim splits.
        # See: https://github.com/christoomey/vim-tmux-navigator
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
        if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'C-\' select-pane -l
      '';
    };

    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/modules/home-manager/nvim-conf";
      recursive = true;
    };
  };
}

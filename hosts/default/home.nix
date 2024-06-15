{ config, pkgs, inputs, vars, ... }:

{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    ../../modules/home-manager
    inputs._1password-shell-plugins.hmModules.default
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = vars.user;
  home.homeDirectory = "/home/${vars.user}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  # tricky's default configs
  t = {
    zsh = true;
    sway = true;

    dev = {
      beam = { enable = true; vscode = true; };
      js = true;
    };
  };

  home.packages = [
    pkgs.gnome.nautilus
    pkgs.firefox-devedition-bin
    pkgs.firefox
    pkgs.obs-studio
    pkgs.vlc
    pkgs.gnupg

    pkgs.file
    pkgs.fzf
    pkgs.ripgrep
    pkgs.wl-clipboard
    pkgs.tree

    pkgs.lua-language-server
    pkgs.nil
  ];

  xdg.configFile."kitty/kitty.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/kitty.conf";
  };

  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nvim";
    recursive = true;
  };

  catppuccin.flavor = "mocha";
  catppuccin.enable = true;
  gtk.enable = false;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    catppuccin.enable = false;
  };

  programs.vscode = {
    enable = true;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir  = false;
  };

  programs._1password-shell-plugins = {
    # enable 1Password shell plugins for bash, zsh, and fish shell
    enable = true;
    # the specified packages as well as 1Password CLI will be
    # automatically installed and configured to use shell plugins
    plugins = with pkgs; [ gh ];
  };
  
  programs.git = {
    enable = true;
    userEmail = "23250792+trickypr@users.noreply.github.com";
    userName = "trickypr";
    extraConfig = {
      gpg.format = "ssh";
      gpg."ssh" = {
        program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
      };
    };
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKZ4NodCumS5eW/0G1xJZ3/MIpKwVxTRhJLodcR5BZg";
      signByDefault = true;
    };
  };

  programs.btop.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

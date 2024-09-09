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
    vnc = true;

    nvim = { enable = true; default = true; };
    vscode = { enable = true; vim = true; };
    kdevelop = { enable = true; };

    dev = {
      direnv = true;
      beam = { enable = true; vscode = true; };
      haskell = { enable = false; vscode = false; };
      js = true;
      kirigami = true;
    };

    _1password = {
      enable = true;
      signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKZ4NodCumS5eW/0G1xJZ3/MIpKwVxTRhJLodcR5BZg";
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
    pkgs.tree

    pkgs.ktailctl
    pkgs.prismlauncher
  ];

  catppuccin.flavor = "latte";
  catppuccin.enable = true;

  programs.git = {
    enable = true;
    userEmail = "git@trickypr.com";
    userName = "trickypr";
  };

  programs.btop.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

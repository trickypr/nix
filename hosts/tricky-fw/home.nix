{
  config,
  pkgs,
  inputs,
  vars,
  ...
}:

{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    inputs.nix-index-database.hmModules.nix-index
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

    nvim = {
      enable = true;
      default = true;
    };
    vscode = {
      enable = false;
      vim = true;
    };

    dev = {
      beam = {
        enable = true;
        vscode = false;
      };
      elm = true;
      haskell = {
        enable = false;
        vscode = false;
      };
      js = true;
      rust = true;
      typst = {
        enable = true;
        nvim = true;
      };
    };

    sudoku = {
      comp2120 = true;
    };

    _1password = {
      enable = true;
      signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKZ4NodCumS5eW/0G1xJZ3/MIpKwVxTRhJLodcR5BZg";
    };
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
  services.mpd = {
    enable = true;
    musicDirectory = "~/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "Pipewire"
      }
    '';
  };

  home.packages = with pkgs; [
    nautilus
    obs-studio
    vlc
    gnupg

    file
    fzf
    ripgrep
    tree

    obsidian
    poetry
  ];

  catppuccin.flavor = "latte";
  catppuccin.enable = true;
  gtk.enable = true;
  gtk.theme = {
    name = "Adwaita";
    package = pkgs.gnome-themes-extra;
  };

  programs.git = {
    enable = true;
    userEmail = "git@trickypr.com";
    userName = "trickypr";
  };

  programs.btop.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

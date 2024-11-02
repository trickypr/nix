# Partial documentation available via
# > man configuration.nix

{ inputs, vars, ... }:
{
  imports = [
    # You will need to generate a hardware configuration with hardware by running
    # > sudo nixos-generate-config
    # and copying the result from /etc/nixos
    ./hardware-configuration.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.default
  ];

  # nixpkgs.hostPlatform = {
  #   gcc.arch = "znver4";
  #   gcc.tune = "znver4";
  #   system = "x86_64-linux";
  # };

  main-user = {
    enable = true;
    userName = vars.user;
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKZ4NodCumS5eW/0G1xJZ3/MIpKwVxTRhJLodcR5BZg";
    homeManager = import ./home.nix;
  };

  networking.hostName = "tricky-desktop";
  networking.networkmanager.enable = true;
  networking.wireless.enable = false; # Enables wireless support via wpa_supplicant.

  services.desktopManager.plasma6.enable = true;

  # services.xserver.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  catppuccin.flavor = "latte";
  catppuccin.enable = true;

  # Applies tricky's configs
  t = {
    grub = true;
    systemd-boot = false;
    plymouth = true;

    # Locale management
    cbr.enable = true;

    devenv.enable = true;

    dm = {
      enable = true;
      keyring = true;
      sway = true;
      sway-vnc = true;
    };

    keyboard = {
      enable = true;
      caps = true;
      gmeta = true;
    };
  };

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  # 1password __MUST__ be installed as root
  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  # steam __MUST__ be installed as root
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  hardware.steam-hardware.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  services.tailscale.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

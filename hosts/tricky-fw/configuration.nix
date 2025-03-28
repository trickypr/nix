# Partial documentation available via
# > man configuration.nix

{
  inputs,
  vars,
  pkgs,
  ...
}:
{
  imports = [
    # You will need to generate a hardware configuration with hardware by running
    # > sudo nixos-generate-config
    # and copying the result from /etc/nixos
    ./hardware-configuration.nix
    ../../modules/nixos
    inputs.home-manager.nixosModules.default
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = [
    pkgs.fprintd
    pkgs.poetry
    pkgs.javacc
    pkgs.scanbd
    pkgs.wireshark
    pkgs.termshark
  ];

  main-user = {
    enable = true;
    userName = vars.user;
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKZ4NodCumS5eW/0G1xJZ3/MIpKwVxTRhJLodcR5BZg";
    homeManager = import ./home.nix;
  };

  services.lpmd.enable = true;

  users.users."kiosk" = {
    isNormalUser = true;
    description = "Kisok User";
    extraGroups = [ "networkmanager" ];
    packages = [ pkgs.firefox ];
  };

  hardware.sane.enable = true;
  services.hardware.bolt.enable = true;

  networking.hostName = "tricky-fw";
  networking.networkmanager.enable = true;
  networking.wireless.enable = false; # Enables wireless support via wpa_supplicant.
  networking.wireguard.enable = true;
  programs.wireshark.enable = true;
  services.tailscale.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Note: Mullvad will not work without systemd-resolved enabled
  # Note: Disabled for boot performace
  # services.mullvad-vpn.enable = true;
  # services.mullvad-vpn.package = pkgs.mullvad-vpn;

  # networking.nameservers = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
  services.resolved = {
    enable = true;
    # dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];
    # dnsovertls = "true";
  };

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.printing.enable = true;
  services.fwupd.enable = true;
  services.fprintd = {
    enable = true;
  };

  programs.java = {
    enable = true;
    package = (pkgs.jdk23.override { enableJavaFX = true; });
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  services.flatpak.enable = true;

  catppuccin.flavor = "latte";
  catppuccin.enable = true;

  # Applies tricky's configs
  t = {
    grub = true;
    systemd-boot = false;
    plymouth = true;
    isGraphical = true;

    # Locale management
    cbr.enable = true;
    devenv.enable = true;

    # System
    bluetooth = true;

    dm = {
      enable = true;
      keyring = true;
      sway = true;
    };

    keyboard = {
      enable = true;
      caps = true;
      gmeta = true;
      dlayer = true;
    };
  };

  programs.neovim.enable = true;
  programs.direnv.enable = true;
  programs.neovim.defaultEditor = true;

  # 1password __MUST__ be installed as root
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "trickypr" ];
  };

  programs.command-not-found.enable = false;
  programs.zsh.interactiveShellInit = ''
    # This function is called whenever a command is not found.
    command_not_found_handler() {
      local p=${pkgs.comma}/bin/comma
      if [ -x $p ]; then
        # Run the helper program.
        $p "$@"
      else
        # Indicate than there was an error so ZSH falls back to its default handler
        echo "$1: command not found" >&2
        return 127
      fi
    }
  '';

  boot.kernelParams = [
    "mitigations=off"
  ];

  # steam __MUST__ be installed as root
  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  # };

  # Enable the OpenSSH daemon.
  #services.openssh = {
  #  enable = true;
  #  settings.PasswordAuthentication = false;
  #  settings.KbdInteractiveAuthentication = false;
  #};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

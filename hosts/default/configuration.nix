# Partial documentation available via
# > man configuration.nix

{
  inputs,
  vars,
  pkgs,
  ...
}:
rec {
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
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.pkgs.mullvad-vpn;

  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.safeeyes.enable = true;

  virtualisation.docker.enable = true;

  # services.xserver.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  catppuccin.flavor = "latte";
  catppuccin.enable = true;

  # Ram disk should be used for builds because zip
  # Note that this my result in build failures
  zramSwap.enable = true;
  boot.tmp = {
    useTmpfs = true;
  };

  # Applies tricky's configs
  t = {
    grub = true;
    systemd-boot = false;
    plymouth = true;
    isGraphical = true;

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
      dlayer = true;
    };
  };

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  networking.firewall.allowedTCPPorts = [ 2222 ];

  programs.ccache.enable = true;
  programs.ccache.cacheDir = "/ccache";
  nix.settings.extra-sandbox-paths = [ programs.ccache.cacheDir ];
  nixpkgs.overlays = [
    (self: super: {
      ccacheWrapper = super.ccacheWrapper.override {
        extraConfig = ''
          export CCACHE_COMPRESS=1
          export CCACHE_DIR="${programs.ccache.cacheDir}"
          export CCACHE_UMASK=007
          if [ ! -d "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' does not exist"
            echo "Please create it with:"
            echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
            echo "  sudo chown root:nixbld '$CCACHE_DIR'"
            echo "====="
            exit 1
          fi
          if [ ! -w "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
            echo "Please verify its access permissions"
            echo "====="
            exit 1
          fi
        '';
      };
    })
  ];

  # 1password __MUST__ be installed as root
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "trickypr" ];
  };
  # steam __MUST__ be installed as root
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Needed to get async reprojection working
  # boot.kernelPatches = [
  #   {
  #     name = "amdgpu-ignore-ctx-privileges";
  #     patch = pkgs.fetchpatch {
  #       name = "cap_sys_nice_begone.patch";
  #       url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
  #       hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
  #     };
  #   }
  # ];

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

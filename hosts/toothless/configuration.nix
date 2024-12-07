{
  inputs,
  vars,
  pkgs,
  ...
}:
{
  imports = [
    # TODO: Hardware config
    ../../modules/nixos
  ];

  networking = {
    hostName = "toothless";
    networkmanager.enable = true;
  };

  catppuccin.flavor = "macchiato";
  catppuccin.enable = true;

  users.users.hickup = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # 🦊
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKZ4NodCumS5eW/0G1xJZ3/MIpKwVxTRhJLodcR5BZg"
      # 🐉
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAbRb2Iug/RGoX13lLCycFa9X1+jT2ptIAiBzvO9XCo kiro@mg187"
    ];
  };

  t = {
    grub = false;
    systemd-boot = true;
    cbr.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Let wheel people login
  security.sudo.wheelNeedsPassword = false;

  services = {
    openssh = {
      enable = true;
      banner = ''
               \****__              ____                                              
                 |    *****\_      --/ *\-__                                          
                 /_          (_    ./ ,/----'                                         
        Art by     \__         (_./  /                                                
         Ironwing     \__           \___----^__                                       
                       _/   _                  \                                      
                |    _/  __/ )\"\ _____         *\                                    
                |\__/   /    ^ ^       \____      )                                   
                 \___--"                    \_____ )                                  
      '';
    };

    jellyfin = {
      enable = true;
    };

    tailscale = {
      enable = true;
      extraUpFlags = [ "--ssh" ];
      permitCertUid = "caddy";
    };

    caddy = {
      enable = true;
      virtualHosts."toothless.boa-tiaki.ts.net".extraConfig = ''
        reverse_proxy 127.0.0.1:8096
      '';
    };
  };

  # VM config for testing
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 3;
      graphics = false;
    };
  };

  # Cleanup and auto update
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  systemd.timers."auto-update" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 4:00:00";
      Unit = "auto-update.service";
    };
  };

  systemd.services."auto-update" = {
    script = ''
      set -euo pipefail
      cd /root

      if [[ ! -e 'nix' ]]; then
        ${pkgs.git}/bin/git clone https://github.com/trickypr/nix.git
      fi

      cd nix
      ${pkgs.git}/bin/git pull

      ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --flake ~/nix#toothless
      ${pkgs.systemd}/bin/reboot
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  system.stateVersion = "24.11";
}

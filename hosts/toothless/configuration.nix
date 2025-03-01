{
  pkgs,
  ...
}:
let
  komga_port = 8080;
  keys = [
    # 🦊
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKZ4NodCumS5eW/0G1xJZ3/MIpKwVxTRhJLodcR5BZg"
    # 🐉
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAbRb2Iug/RGoX13lLCycFa9X1+jT2ptIAiBzvO9XCo kiro@mg187"
  ];

in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  networking = {
    hostName = "toothless";
    networkmanager.enable = true;
  };

  catppuccin.flavor = "latte";
  catppuccin.enable = true;

  users = {
    users = {
      hickup = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        packages = with pkgs; [
          git
          btop
        ];
        openssh.authorizedKeys.keys = keys;
      };

      git = {
        home = "/var/lib/git-server";
        isSystemUser = true;
        group = "git";
        shell = "${pkgs.git}/bin/git-shell";
        createHome = true;
        openssh.authorizedKeys.keys = keys;
      };
    };

    groups.git = { };
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
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "dns@trickypr.com";
      # dnsResolver = "1.1.1.1:53"; # Don't trust local dns
      # DNS is unreliable, check
      extraLegoFlags = [
        "--dns.propagation-wait"
        "60s"
      ];
    };
    certs."t.trickypr.com" = {
      domain = "t.trickypr.com";
      extraDomainNames = [ "*.t.trickypr.com" ];
      dnsProvider = "cloudflare";
      group = "nginx";
      environmentFile = "/etc/nixos/cf";
    };
  };

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

      extraConfig = ''
        Match user git
          AllowTcpForwarding no
          AllowAgentForwarding no
          PasswordAuthentication no
          PermitTTY no
          X11Forwarding no
      '';
    };

    jellyfin = {
      enable = true;
    };

    komga = {
      enable = true;
      port = komga_port;
      stateDir = "/mnt/media/komga";
    };

    cgit.default = {
      enable = true;
      nginx.virtualHost = "git.t.trickypr.com";
      package = pkgs.cgit-pink;
      scanPath = "/var/lib/git-server";
    };

    tailscale = {
      enable = true;
      extraUpFlags = [ "--ssh" ];
      permitCertUid = "caddy";
    };

    nginx = {
      enable = true;
      virtualHosts = {
        "jellyfin.t.trickypr.com" = {
          forceSSL = true;
          useACMEHost = "t.trickypr.com";
          locations."/".proxyPass = "http://127.0.0.1:8096";
        };

        "komga.t.trickypr.com" = {
          forceSSL = true;
          useACMEHost = "t.trickypr.com";
          locations."/".proxyPass = "http://127.0.0.1:${toString komga_port}";
        };

        "git.t.trickypr.com" = {
          forceSSL = true;
          useACMEHost = "t.trickypr.com";
        };
      };
    };

    resolved = {
      enable = true;
      domains = [ "~." ];
      fallbackDns = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
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

  # Access to network media share
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/nas" = {
    device = "//nas.local/Media";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in
      [ "${automount_opts},credentials=/etc/nixos/smb-secrets" ];
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

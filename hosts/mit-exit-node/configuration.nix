{
  inputs,
  vars,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/nixos
  ];

  networking = {
    hostName = "mit-exit-node";
    networkmanager.enable = true;
  };

  users.users.node = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = [ pkgs.mitmproxy ];
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

    tailscale = {
      enable = true;
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -i tailscale0 -p tcp --dport 80 -j REDIRECT --to-port 8080
    iptables -t nat -A PREROUTING -i tailscale0 -p tcp --dport 443 -j REDIRECT --to-port 8080
    ip6tables -t nat -A PREROUTING -i tailscale0 -p tcp --dport 80 -j REDIRECT --to-port 8080
    ip6tables -t nat -A PREROUTING -i tailscale0 -p tcp --dport 443 -j REDIRECT --to-port 8080
  '';

  # VM config for testing
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 3;
      graphics = false;
    };
  };

  system.stateVersion = "24.11";
}

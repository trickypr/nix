{
  pkgs,
  ...
}:
let
  start = pkgs.writeShellScriptBin "start" ''
    sudo tailscale login --advertise-exit-node --qr
    ${pkgs.mitmproxy}/bin/mitmproxy --mode transparent
  '';
in
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
    packages = [ start ];
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
      banner = '''';
    };

    tailscale = {
      enable = true;
      extraDaemonFlags = [ "--state=mem:" ];
    };

    getty.autologinUser = "node";
  };

  programs.bash.loginShellInit = ''
    echo "         \****__              ____              "
    echo "           |    *****\_      --/ *\-__          "
    echo "           /_          (_    ./ ,/----'         "
    echo "  Art by     \__         (_./  /                "
    echo "   Ironwing     \__           \___----^__       "
    echo "                 _/   _                  \      "
    echo "          |    _/  __/ )\"\ _____         *\    "
    echo "          |\__/   /    ^ ^       \____      )   "
    echo '           \___--"                    \_____ )  '
  '';

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
      cores = 2;
      graphics = false;
    };
  };

  system.stateVersion = "24.11";
}

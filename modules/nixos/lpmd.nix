{ lib, config, pkgs, ... }:

let
  lpmd-pkg = pkgs.callPackage ./lpmd-pkg.nix { };
  cfg = config.services.lpmd;
in 
{
  options.services.lpmd = {
    enable = lib.mkEnableOption "enable display manager module";
  };

  config = lib.mkIf cfg.enable {
    services.dbus.packages = [ lpmd-pkg ];
    systemd.packages = [ lpmd-pkg ];
    environment.systemPackages = [ 
      lpmd-pkg
    ];

    systemd.services.intel_lpmd = {
      enable = true;
    };
  };
}

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
    environment.systemPackages = [ lpmd-pkg ];
    services.dbus.packages = [ lpmd-pkg ];
    systemd.packages = [ lpmd-pkg ];

   # systemd.services.lpmd = {
   #   enable = true;
   #   description = "Intel Low Power Daemon Service";
   #   wantedBy = [ "multi-user.target" ];
   #   # aliases = [ "org.freedesktop.intel_lpmd.service" ];

   #   serviceConfig = {
   #     Type = "dbus";
   #     SuccessExitStatus = "2";
   #     BusName = "org.freedesktop.intel_lpmd";
   #     ExecStart = "${lpmd-pkg}/bin/intel_lpmd --systemd --dbus-enable";
   #     Restart = "on-failure";
   #   };
   # };
  };
}

{
  lib,
  config,
  pkgs,
  ...
}:

let
  lpmd-pkg = pkgs.callPackage ./lpmd-pkg.nix { };
  cfg = config.services.lpmd;

  lpmd-config = pkgs.writeText "lpmd_config.xml" ''
    <?xml version="1.0"?>
    <Configuration>
    	<lp_mode_cpus></lp_mode_cpus>
    	<Mode>${cfg.mode}</Mode>
    	<PerformanceDef>${cfg.peformance}</PerformanceDef>
    	<BalancedDef>${cfg.balanced}</BalancedDef>
    	<PowersaverDef>${cfg.powersaver}</PowersaverDef>
    	<HfiLpmEnable>${cfg.hfi-lpm}</HfiLpmEnable>
    	<HfiSuvEnable>${cfg.hfi-suv}</HfiSuvEnable>
    	<util_entry_threshold>10</util_entry_threshold>
    	<util_exit_threshold>95</util_exit_threshold>
    	<EntryDelayMS>0</EntryDelayMS>
    	<ExitDelayMS>0</ExitDelayMS>
    	<EntryHystMS>0</EntryHystMS>
    	<ExitHystMS>0</ExitHystMS>
    	<IgnoreITMT>0</IgnoreITMT>
    </Configuration>
  '';
  lpmd-pkg-with-conf = lpmd-pkg.overrideAttrs (
    finalAttrs: previousAttrs: {
      postInstall = ''
        rm -rf ${placeholder "out"}/lib/systemd/system
        cp ${lpmd-config} ${placeholder "out"}/etc/intel_lpmd/intel_lpmd_config.xml
      '';
    }
  );
in
{
  options.services.lpmd = {
    enable = lib.mkEnableOption "enable display manager module";
    mode = lib.mkOption {
      default = "0";
      description = ''
        What mode LPMD
        - 0: Cgroup v2
        - 1: Cgroup v2 isolate
        - 2: CPU idle injection
      '';
    };
    peformance = lib.mkOption {
      default = "-1";
      description = ''
        Default behavior when Performance power setting is used
        - -1: force off. (Never enter Low Power Mode)
        - 1: force on. (Always stay in Low Power Mode)
        - 0: auto. (opportunistic Low Power Mode enter/exit)
      '';
    };
    balanced = lib.mkOption {
      default = "0";
      description = ''
        Default behavior when Performance power setting is used
        - -1: force off. (Never enter Low Power Mode)
        - 1: force on. (Always stay in Low Power Mode)
        - 0: auto. (opportunistic Low Power Mode enter/exit)
      '';
    };
    powersaver = lib.mkOption {
      default = "0";
      description = ''
        Default behavior when Performance power setting is used
        - -1: force off. (Never enter Low Power Mode)
        - 1: force on. (Always stay in Low Power Mode)
        - 0: auto. (opportunistic Low Power Mode enter/exit)
      '';
    };
    hfi-lpm = lib.mkOption {
      default = "0";
      description = ''
        Use HFI LPM hints
        0 : No
        1 : Yes
      '';
    };
    hfi-suv = lib.mkOption {
      default = "0";
      description = ''
        Use HFI SUV hints
        0 : No
        1 : Yes
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.dbus.packages = [ lpmd-pkg-with-conf ];
    systemd.packages = [ lpmd-pkg-with-conf ];
    environment.systemPackages = [
      lpmd-pkg-with-conf
    ];

    systemd.services.intel_lpmd = {
      enable = true;
      description = "Intel Low Power Daemon Service";
      wantedBy = [ "multi-user.target" ];
      aliases = [ "org.freedesktop.intel_lpmd.service" ];

      serviceConfig = {
        Type = "dbus";
        SuccessExitStatus = "2";
        BusName = "org.freedesktop.intel_lpmd";
        ExecStart = "${lpmd-pkg-with-conf}/bin/intel_lpmd --systemd --dbus-enable";
        Restart = "on-failure";
      };
    };
  };
}

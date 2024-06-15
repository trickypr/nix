{ lib, config, pkgs, ... }:

let
  cfg = config.t.devenv;
in
{
  options = {
    t.devenv.enable = lib.mkEnableOption "enable devenv module";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.devenv
    ];

    nix.settings = {
      trusted-users = [ "root" config.main-user.userName ];
      extra-substituters = "https://devenv.cachix.org";
      extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    };
  };
}

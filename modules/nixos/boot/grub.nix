{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.t.grub;
in
{
  options = {
    t.grub = lib.mkEnableOption "enable grub boot";
  };

  config = lib.mkIf cfg {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
    };
  };
}

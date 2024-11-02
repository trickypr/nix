{ lib, config, ... }:

let
  cfg = config.t.keyboard;
  tap-time = "150";
  hold-time = "200";
in
{
  options.t.keyboard = {
    enable = lib.mkEnableOption "enable keybinding management";
    caps = lib.mkEnableOption "Rebinds capslock to both esc and ctrl";
    gmeta = lib.mkEnableOption "rebinds g hold to meta";
  };

  config = lib.mkIf cfg.enable {
    services.kanata.enable = true;
    services.kanata.keyboards.default = {
      extraDefCfg = lib.optionalString cfg.gmeta "process-unmapped-keys yes";
      config = 
        ''
          (defsrc 
            ${lib.optionalString cfg.caps "caps"}
            ${lib.optionalString cfg.gmeta "g"}
          )

          (defalias
            ${lib.optionalString cfg.caps "caps (tap-hold ${tap-time} ${hold-time} esc lctl)"}
            ${lib.optionalString cfg.gmeta "g (tap-hold ${tap-time} ${hold-time} g lmet)"}
          )
          
          (deflayer base 
            ${lib.optionalString cfg.caps "@caps"}
            ${lib.optionalString cfg.gmeta "@g"}
          )
        '';
    };
  };
}

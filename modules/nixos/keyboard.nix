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
    dlayer = lib.mkEnableOption "creates a keyboard layer when holding down d";
  };

  config = lib.mkIf cfg.enable {
    services.kanata.enable = true;
    services.kanata.keyboards.default = {
      extraDefCfg = lib.optionalString cfg.gmeta "process-unmapped-keys yes";
      config = ''
        (defsrc 
          ${lib.optionalString cfg.caps "caps"}
          ${lib.optionalString cfg.gmeta "g"}
          ${lib.optionalString cfg.dlayer "d h j k l"}
        )

        (defalias
          ${lib.optionalString cfg.caps "caps (tap-hold ${tap-time} ${hold-time} esc lctl)"}
          ${lib.optionalString cfg.gmeta "g (tap-hold ${tap-time} ${hold-time} g lmet)"}
          ${lib.optionalString cfg.dlayer "d (tap-hold  ${tap-time} ${hold-time} d (layer-while-held dlayer))"}
        )

        (deflayer base 
          ${lib.optionalString cfg.caps "@caps"}
          ${lib.optionalString cfg.gmeta "@g"}
          ${lib.optionalString cfg.dlayer "@d _ _ _ _"}
        )

        ${lib.optionalString cfg.dlayer ''
          (deflayer dlayer
            ${lib.optionalString cfg.caps "_"}
            ${lib.optionalString cfg.gmeta "_"}
            _ left down up right
          )
        ''}
      '';
    };
  };
}

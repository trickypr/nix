{ lib, config, ... }:

let
  cfg = config.t.keyboard;
in
{
  options.t.keyboard = {
    enable = lib.mkEnableOption "enable keybinding management";
    caps = lib.mkEnableOption "Rebinds capslock to both esc and ctrl";
  };

  config = lib.mkIf cfg.enable {
    services.kanata.enable = true;
    services.kanata.keyboards.default = {
      config = 
        ''
          (defsrc ${lib.optionalString cfg.caps "caps"})
          
          (deflayermap (default-layer) 
            ${lib.optionalString cfg.caps "caps (tap-hold 100 100 esc lctl)"})
        '';
    };
  };
}

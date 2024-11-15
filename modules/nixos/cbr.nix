# Locale management
{ config, lib, ... }:

let
  cfg = config.t.cbr;
in
{
  options = {
    t.cbr.enable = lib.mkEnableOption "enable canberrra (locale) module";
    t.cbr.locale = lib.mkOption {
      default = "en_AU.UTF-8";
      description = "your language, dialect and characterset";
    };
    t.cbr.timeZone = lib.mkOption {
      default = "Australia/Sydney";
      description = "your timezone";
    };
    t.cbr.kbLayout = lib.mkOption {
      default = "au";
      description = "your keyboard layout";
    };
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = cfg.timeZone;

    # Select internationalisation properties.
    i18n.defaultLocale = cfg.locale;

    i18n.extraLocaleSettings = {
      LC_ADDRESS = cfg.locale;
      LC_IDENTIFICATION = cfg.locale;
      LC_MEASUREMENT = cfg.locale;
      LC_MONETARY = cfg.locale;
      LC_NAME = cfg.locale;
      LC_NUMERIC = cfg.locale;
      LC_PAPER = cfg.locale;
      LC_TELEPHONE = cfg.locale;
      LC_TIME = cfg.locale;
    };

    # Configure keymap in X11
    services.xserver = {
      xkb.layout = cfg.kbLayout;
      xkb.variant = "";
    };
  };
}

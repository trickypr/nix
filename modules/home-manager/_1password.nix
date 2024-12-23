{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.t._1password;
in
{
  options = {
    t._1password.enable = lib.mkEnableOption "enables 1password module";
    t._1password.signingKey = lib.mkOption {
      description = "The key (in your 1password vault) that should be used to sign git commits";
    };
  };

  config = lib.mkIf cfg.enable {
    programs._1password-shell-plugins = {
      # enable 1Password shell plugins for bash, zsh, and fish shell
      enable = true;
      # the specified packages as well as 1Password CLI will be
      # automatically installed and configured to use shell plugins
      plugins = with pkgs; [ gh ];
    };

    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host *
        	IdentityAgent ~/.1password/agent.sock
      '';
    };

    programs.git = {
      enable = true;
      extraConfig = {
        gpg.format = "ssh";
        gpg."ssh" = {
          program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
        };
      };
      signing = {
        key = cfg.signingKey;
        signByDefault = true;
      };
    };
  };
}

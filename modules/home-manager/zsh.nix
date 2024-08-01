
{ lib, config, pkgs, ... }:

let
  cfg = config.t.zsh;
in
{
  options = {
    t.zsh = lib.mkEnableOption "enable zsh module";
  };

  config = lib.mkIf cfg {
    home.packages = [
      pkgs.zsh-powerlevel10k
    ];

    home.sessionPath = [
      "/home/trickypr/.local/share/JetBrains/Toolbox/scripts"
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      initExtra = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme; source ~/.config/.p10k.zsh";
      autosuggestion = {
        enable = true;
      };
      history = {
        ignoreAllDups = true;
      };
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    xdg.configFile.".p10k.zsh".source = ./p10k.zsh;
  };
}

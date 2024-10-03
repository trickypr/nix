{
  lib,
  config,
  pkgs,
  ...
}:

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
      # initExtra = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme; source ~/.config/.p10k.zsh\nalias x='${pkgs.zellij}/bin/zellij'";
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

    programs.oh-my-posh = {
      enable = true;
      settings = {
        version = 2;
        transient_prompt = {
          foreground = "black";
          background = "transparent";
          template = "❭ ";
        };

        blocks = [
          {
            type = "rprompt";
            alignment = "right";
            segments = [
              {
                type = "session";
                style = "plain";
                template = "{{ if .SSHSession }}  {{ .HostName }}{{ end }}";
              }

              {
                type = "nix-shell";
                style = "plain";
                template = "{{ if ne .Type \"unknown\" }} {{.Type}}{{ end }}";
              }
            ];
          }

          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "path";
                style = "plain";
                template = "{{ .Path }}";
                background = "transparent";
                foreground = "black";
                properties.styles = "full";
              }

              {
                type = "git";
                style = "plain";
                foreground = "lightGreen";
                properties = {
                  fetch_status = true;
                  fetch_upstream_icon = true;
                };
              }
            ];
          }

          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "text";
                style = "plain";
                foreground = "black";
                background = "transparent";
                template = "❭ ";
              }
            ];
          }
        ];

      };
    };
  };
}

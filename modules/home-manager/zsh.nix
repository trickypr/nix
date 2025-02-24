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
    home.sessionPath = [
      "/home/trickypr/.local/share/JetBrains/Toolbox/scripts"
    ];

    programs.command-not-found.enable = false;
    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enableZshIntegration = false;
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
      };
      history = {
        ignoreAllDups = true;
      };
      initExtra = ''
        # This function is called whenever a command is not found.
        command_not_found_handler() {
          local p=${pkgs.comma}/bin/comma
          if [ -x $p ]; then
            # Run the helper program.
            $p "$@"
          else
            # Indicate than there was an error so ZSH falls back to its default handler
            echo "$1: command not found" >&2
            return 127
          fi
        }

        # 1password socket
        [[ -z $SSH_AUTH_SOCK ]] && export SSH_AUTH_SOCK=~/.1password/agent.sock
      '';
    };

    programs.zoxide.enable = true;

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

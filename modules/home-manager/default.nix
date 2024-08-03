{
  imports = [
    ./dev
    ./_1password.nix
    ./kdevelop.nix
    ./sway.nix
    ./vscode.nix
    ./zsh.nix

    # Depends on above
    ./nvim.nix
  ];
}

{
  imports = [
    ./dev
    ./_1password.nix
    ./sway.nix
    ./zsh.nix

    # Depends on above
    ./nvim.nix
  ];
}

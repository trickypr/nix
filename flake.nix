{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprmag.url = "github:SIMULATAN/hyprmag";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            vars = {
              user = "trickypr";
            };
          };
          modules = [
            ./hosts/default/configuration.nix
            inputs.catppuccin.nixosModules.catppuccin
            inputs.home-manager.nixosModules.default
            inputs.nix-index-database.nixosModules.nix-index
            { programs.nix-index-database.comma.enable = true; }
          ];
        };

        tricky-fw = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            vars = {
              user = "trickypr";
            };
          };
          modules = [
            ./hosts/tricky-fw/configuration.nix
            inputs.catppuccin.nixosModules.catppuccin
            inputs.home-manager.nixosModules.default
            inputs.nix-index-database.nixosModules.nix-index
            { programs.nix-index-database.comma.enable = true; }
          ];
        };
      };
    };
}

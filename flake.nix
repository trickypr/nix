{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Induvidual packages
    hyprmag.url = "github:SIMULATAN/hyprmag";
    emmet-helper.url = "github:trickypr/emmet-helper";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        default =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem

            {
              specialArgs = {
                inherit inputs;
                inherit system;
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

        tricky-fw =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              inherit system;
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

        toothless =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./hosts/toothless/configuration.nix
              inputs.catppuccin.nixosModules.catppuccin
              # These modules are required for evaluation but are unused
              inputs.home-manager.nixosModules.default
            ];
          };

        mit-exit-node =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./hosts/mit-exit-node/configuration.nix
              # These modules are required for evaluation but are unused
              inputs.home-manager.nixosModules.default
              inputs.catppuccin.nixosModules.catppuccin
            ];
          };

      };

    };
}

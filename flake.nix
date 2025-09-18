{
  description = "My personal configuration flake";

  inputs = {

    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    nixvim-config = {
      url = "github:petterhs/nixvim-config";
    };

  };

  outputs =
    {
      nixpkgs,
      catppuccin,
      home-manager,
      hyprland,
      nixvim-config,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import ./overlays/teams-for-linux.nix)
        ];
        config = {
          allowUnfree = true;
        };
      };
      
      # Common modules for all hosts
      commonModules = [
        catppuccin.nixosModules.catppuccin
        ./modules/common/nix.nix
        ./modules/common/system.nix
        ./modules/common/hyprland.nix
        ./modules/common/development.nix
        ./modules/common/graphical.nix
        ./modules/common/teams.nix
        ./modules/common/home-manager.nix
        home-manager.nixosModules.home-manager
      ];
    in
    {
      nixosConfigurations = {
        "nixdesktop" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs;
          };
          modules = commonModules ++ [
            ./hosts/nixdesktop/hardware-configuration.nix
            ./modules/hosts/nixdesktop.nix
            ./modules/hosts/nixdesktop-btc.nix
            {
              home-manager.users.petter = {
                imports = [
                  ./home/users/petter.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
              home-manager.extraSpecialArgs = {
                inherit nixvim-config;
              };
            }
          ];
        };
        "no-kon-lx-016" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = commonModules ++ [
            ./hosts/no-kon-lx-016/hardware-configuration.nix
            ./modules/hosts/no-kon-lx-016.nix
            {
              home-manager.users.s27731 = {
                imports = [
                  ./home/users/s27731.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
              home-manager.extraSpecialArgs = {
                inherit nixvim-config;
              };
            }
          ];
        };
      };
    };
}

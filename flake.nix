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
    in
    {
      nixosConfigurations = {
        "nixdesktop" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs;
          };
          modules = [
            catppuccin.nixosModules.catppuccin
            ./hosts/nixdesktop/configuration.nix
            ./nix/btc.nix
            { programs.hyprland.enable = true; }
            home-manager.nixosModules.home-manager
            {
              lib.homeManagerConfiguration = {
                pkgs = nixpkgs.legacyPackages.x86_64-linux;
                modules = [
                  hyprland.homeManagerModules.default
                  { wayland.windowManager.hyprland.enable = true; }
                ];
              };
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.petter = {
                  imports = [
                    ./home/users/petter.nix
                    catppuccin.homeModules.catppuccin
                  ];
                };
                extraSpecialArgs = {
                  inherit nixvim-config;
                };
              };
            }
          ];
        };
        "no-kon-lx-016" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            catppuccin.nixosModules.catppuccin
            ./hosts/no-kon-lx-016/configuration.nix
            {
              nixpkgs.overlays = [
                (import ./overlays/teams-for-linux.nix)
              ];
            }
            home-manager.nixosModules.home-manager
            {
              lib.homeManagerConfiguration = {
                pkgs = nixpkgs.legacyPackages.x86_64-linux;
                modules = [
                ];
              };
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.s27731 = {
                  imports = [
                    ./home/users/s27731.nix
                    catppuccin.homeModules.catppuccin
                  ];
                };
                extraSpecialArgs = {
                  inherit nixvim-config;
                };
              };
            }
          ];
        };
      };
    };
}

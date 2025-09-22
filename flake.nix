{
  description = "My personal configuration flake";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
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
          (import ./overlays/home-assistant-custom.nix)
        ];
        config = {
          allowUnfree = true;
        };
      };
      
      # Common modules for all hosts
      commonModules = [
        catppuccin.nixosModules.catppuccin
        # Ensure overlays are applied inside NixOS evaluation
        { nixpkgs.overlays = [
            (import ./overlays/teams-for-linux.nix)
            (import ./overlays/home-assistant-custom.nix)
          ];
        }
        ./modules/common/nix.nix
        ./modules/common/system.nix
        ./modules/common/hyprland.nix
        ./modules/common/development.nix
        ./modules/common/graphical.nix
        ./modules/common/teams.nix
        ./modules/common/home-manager.nix
        home-manager.nixosModules.home-manager
      ];

      # Homelab modules (for littleboy)
      homelabModules = [
        ./modules/homelab/default.nix
      ];

      # Server modules (for littleboy - headless)
      serverModules = [
        # Ensure overlays are applied inside NixOS evaluation
        { nixpkgs.overlays = [
            (import ./overlays/home-assistant-custom.nix)
          ];
        }
        ./modules/common/nix.nix
        ./modules/common/server.nix
        ./modules/common/server-development.nix
        ./modules/common/server-home-manager.nix
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
        "littleboy" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = serverModules ++ homelabModules ++ [
            ./hosts/littleboy/hardware-configuration.nix
            ./modules/hosts/littleboy.nix
            {
              environment.systemPackages = [
                # Additional server packages can be added here
              ];
            }
            {
              home-manager.users.petter = {
                imports = [
                  ./home/users/littleboy-server.nix
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

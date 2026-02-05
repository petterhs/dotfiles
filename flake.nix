{
  description = "My personal configuration flake";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    nixvim-config = {
      url = "github:petterhs/nixvim-config";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      nixpkgs,
      catppuccin,
      home-manager,
      hyprland,
      nixvim-config,
      sops-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          # (import ./overlays/teams-for-linux.nix)
          (import ./overlays/home-assistant-custom.nix)
          (import ./overlays/librespot-ma.nix)
        ];
        config = {
          allowUnfree = true;
        };
      };

      # Common modules for all hosts
      commonModules = [
        catppuccin.nixosModules.catppuccin
        sops-nix.nixosModules.sops
        # Ensure overlays are applied inside NixOS evaluation
        {
          nixpkgs.overlays = [
            # (import ./overlays/teams-for-linux.nix)
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
        ./modules/common/secrets.nix
        home-manager.nixosModules.home-manager
      ];

      # Homelab modules (for littleboy)
      homelabModules = [
        ./modules/homelab/default.nix
      ];

      # Server modules (for littleboy - headless)
      serverModules = [
        sops-nix.nixosModules.sops
        # Ensure overlays are applied inside NixOS evaluation
        {
          nixpkgs.overlays = [
            (import ./overlays/home-assistant-custom.nix)
          ];
        }
        ./modules/common/nix.nix
        ./modules/common/server.nix
        ./modules/common/server-development.nix
        ./modules/common/server-home-manager.nix
        ./modules/common/secrets.nix
        home-manager.nixosModules.home-manager
      ];
    in
    {
      nixosConfigurations = {
        "fatman" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs;
          };
          modules = commonModules ++ [
            ./hosts/fatman/hardware-configuration.nix
            ./modules/hosts/fatman.nix
            ./modules/hosts/fatman-btc.nix
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
          modules =
            serverModules
            ++ homelabModules
            ++ [
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

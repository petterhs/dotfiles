{
  description = "My personal configuration flake";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    catppuccin.url = "github:catppuccin/nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hermes-agent.url = "github:NousResearch/hermes-agent";

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
      nixos-hardware,
      hermes-agent,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import ./overlays/home-assistant-custom.nix)
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

      # Lean modules for Raspberry Pi hosts (no EFI / Docker / PipeWire)
      piServerModules = [
        sops-nix.nixosModules.sops
        ./modules/common/nix.nix
        ./modules/common/rpi-server.nix
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
        "travis" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules =
            piServerModules
            ++ [
              nixos-hardware.nixosModules.raspberry-pi-4
              hermes-agent.nixosModules.default
              ./hosts/travis/hardware-configuration.nix
              ./modules/hosts/travis.nix
              ./modules/hosts/travis/hermes.nix
              {
                home-manager.users.petter = {
                  imports = [
                    ./home/users/travis-server.nix
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

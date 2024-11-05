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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-config = {
      url = "github:petterhs/nixvim-config";
    };

    zen-browser.url = "github:heywoodlh/flakes/main?dir=zen-browser";

  };

  outputs =
    {
      nixpkgs,
      catppuccin,
      home-manager,
      hyprland,
      nixvim-config,
      zen-browser,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ];
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
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
            {
              environment.systemPackages = [
                zen-browser.packages.x86_64-linux.zen-browser
              ];
            }
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
                    catppuccin.homeManagerModules.catppuccin
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
            inherit inputs pkgs;
          };
          modules = [
            catppuccin.nixosModules.catppuccin
            ./hosts/no-kon-lx-016/configuration.nix
            { programs.hyprland.enable = true; }
            {
              environment.systemPackages = [
                zen-browser.packages.x86_64-linux.zen-browser
              ];
            }
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
                users.s27731 = {
                  imports = [
                    ./home/users/s27731.nix
                    catppuccin.homeManagerModules.catppuccin
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

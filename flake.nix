{
  description = "My personal configuration flake";

  inputs = {

    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nix-bitcoin/nixpkgs-unstable";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nix-bitcoin/nixpkgs-unstable";
    };
    nixvim-config = {
      url = "github:petterhs/nixvim-config";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, nixvim-config, ... }@inputs: {
    nixosConfigurations = {
      "nixdesktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixdesktop/configuration.nix
          ./nix/btc.nix
          { programs.hyprland.enable = true; }
          home-manager.nixosModules.home-manager
          {
            lib.homeManagerConfiguration = {
              pkgs = nixpkgs.legacyPackages.x86_64-linux;
              modules = [
                hyprland.homeManagerModules.default
                {wayland.windowManager.hyprland.enable = true;}
              ];
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.petter = import ./home/users/petter.nix;
            home-manager.users.petter-work = import ./home/users/petter-work.nix;
          }
        ];
      };
      "no-kon-lx-016" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/no-kon-lx-016/configuration.nix
          { programs.hyprland.enable = true; }
          home-manager.nixosModules.home-manager
          {
            lib.homeManagerConfiguration = {
              pkgs = nixpkgs.legacyPackages.x86_64-linux;
              modules = [
                hyprland.homeManagerModules.default
                {wayland.windowManager.hyprland.enable = true;}
              ];
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.s27731 = import ./home/users/s27731.nix;
            home-manager.extraSpecialArgs = {inherit nixvim-config;};
          }
        ];
      };
    };
    homeConfigurations."s27731" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      
      modules = [
        hyprland.homeManagerModules.default
        {
          nixpkgs.config.allowUnfree = true;
        }

        ./home/users/s27731.nix
      ];
    };
  };
}

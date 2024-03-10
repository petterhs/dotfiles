{
  description = "My personal configuration flake";

  inputs = {


    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";

      inputs.nixpkgs.follows = "nix-bitcoin/nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      "nixdesktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixdesktop/configuration.nix
          ./nix/btc.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.petter = import ./home/users/petter.nix;
            home-manager.users.petter-work = import ./home/users/petter-work.nix;
          }

        ];
      };
    };
  };
}

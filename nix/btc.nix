let
  nix-bitcoin = builtins.fetchTarball {
    url = "https://github.com/fort-nix/nix-bitcoin/archive/v0.0.100.tar.gz";
    sha256 = "sha256-6/T8h7g0s5Kp2C4yCOyuL9ssfPsZ237l2ek5Kc6r+eM=";
  };
in
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    "${nix-bitcoin}/modules/modules.nix"
  ];

  # Automatically generate all secrets required by services.
  # The secrets are stored in /etc/nix-bitcoin-secrets
  nix-bitcoin.generateSecrets = true;

  # Enable some services.
  # See ./configuration.nix for all available features.
  services.bitcoind = {
    enable = true;
    dataDir = "/node/bitcoin/";

    # Listen to RPC connections on all interfaces
    rpc.address = "0.0.0.0";

    # Allow RPC connections from external addresses
    rpc.allowip = [
      "10.10.0.0/24" # Allow a subnet
      "192.168.0.0/24" # Allow a specific address
      "0.0.0.0/0" # Allow all addresses
    ];
  };

  services.electrs.enable = true;

  # Enable interactive access to nix-bitcoin features (like bitcoin-cli) for
  # your system's main user
  nix-bitcoin.operator = {
    enable = true;
    name = "petter";
  };

  # Prevent garbage collection of the nix-bitcoin source
  system.extraDependencies = [ nix-bitcoin ];
}

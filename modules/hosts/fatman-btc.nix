# Bitcoin node configuration for fatman (nix-bitcoin flake input)
{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-bitcoin.nixosModules.default
  ];

  # nix-bitcoin's bitcoind module always reads services.i2pd.proto.sam (even with
  # i2p = false). nixos-unstable removed `proto` in favour of `settings`, so stub
  # the old options for evaluation compatibility. Do not enable bitcoind.i2p
  # until nix-bitcoin supports the new i2pd module.
  options.services.i2pd.proto.sam = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Stub for nix-bitcoin; unused with bitcoind.i2p = false.";
    };
    address = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 7656;
    };
  };

  config = {
    # Use pkgs versions tested by nix-bitcoin while the rest of fatman stays on
    # this flake's nixos-unstable. See nix-bitcoin flake examples.
    nix-bitcoin.useVersionLockedPkgs = true;

    # Automatically generate all secrets required by services.
    # The secrets are stored in /etc/nix-bitcoin-secrets
    nix-bitcoin.generateSecrets = true;

    services.bitcoind = {
      enable = true;
      i2p = false;
      dataDir = "/node/bitcoin/";

      # Listen to RPC connections on all interfaces
      rpc.address = "0.0.0.0";

      # Allow RPC connections from external addresses
      rpc.allowip = [
        "10.10.0.0/24"
        "192.168.0.0/24"
        "0.0.0.0/0"
      ];
    };

    services.electrs.enable = true;

    # Interactive access to nix-bitcoin features (like bitcoin-cli) for petter
    nix-bitcoin.operator = {
      enable = true;
      name = "petter";
    };
  };
}

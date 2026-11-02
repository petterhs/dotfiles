# Hermes Agent + signal-cli for travis
{
  config,
  lib,
  pkgs,
  ...
}:
let
  travisSecrets = ../../../secrets/travis.yaml;
in
{
  sops.secrets."hermes-env" = {
    sopsFile = travisSecrets;
    key = "hermes_env";
    owner = "petter";
    group = "users";
    mode = "0400";
  };

  sops.secrets."signal-cli-account" = {
    sopsFile = travisSecrets;
    key = "signal_cli_account";
    owner = "signal-cli";
    group = "signal-cli";
    mode = "0400";
  };

  users.groups.signal-cli = { };
  users.users.signal-cli = {
    isSystemUser = true;
    group = "signal-cli";
    home = "/var/lib/signal-cli";
    createHome = true;
  };

  environment.systemPackages = [ pkgs.signal-cli ];

  systemd.services.signal-cli = {
    description = "signal-cli HTTP daemon for Hermes";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      User = "signal-cli";
      Group = "signal-cli";
      WorkingDirectory = "/var/lib/signal-cli";
      StateDirectory = "signal-cli";
      Environment = [ "HOME=/var/lib/signal-cli" ];
      ExecStart = pkgs.writeShellScript "signal-cli-daemon" ''
        set -euo pipefail
        ACCOUNT="$(${pkgs.coreutils}/bin/tr -d '[:space:]' < ${config.sops.secrets."signal-cli-account".path})"
        if [ -z "$ACCOUNT" ] || [ "$ACCOUNT" = "REPLACE_ME" ]; then
          echo "signal-cli: set signal_cli_account in secrets/travis.yaml (E.164 phone number)" >&2
          exit 1
        fi
        exec ${pkgs.signal-cli}/bin/signal-cli -a "$ACCOUNT" daemon --http 127.0.0.1:8080
      '';
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  services.hermes-agent = {
    enable = true;
    user = "petter";
    group = "users";
    createUser = false;
    addToSystemPackages = true;
    environmentFiles = [ config.sops.secrets."hermes-env".path ];
    settings = {
      model.default = "deepseek/deepseek-v4.1-flash";
    };
  };

  # Hermes keeps state.db and its control socket owner-only. Run the gateway
  # as the interactive user so the CLI and service share the same state.
  users.users.petter.linger = true;

  # Migrate state created by the former dedicated service account.
  system.activationScripts."hermes-agent-state-owner" =
    lib.stringAfter [ "hermes-agent-setup" ] ''
      find /var/lib/hermes/.hermes -xdev \
        \( \! -user petter -o \! -group users \) \
        -exec chown -h petter:users {} +
    '';

  # Start Hermes after signal-cli is up
  systemd.services.hermes-agent = {
    after = [ "signal-cli.service" ];
    wants = [ "signal-cli.service" ];
  };
}

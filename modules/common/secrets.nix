# Secrets configuration and deployment for sops-nix
# This file handles both sops configuration and deploying secrets to users
#
# IMPORTANT: Only the private key is encrypted. The public key is stored as plain text.
# See docs/travis.md for host-key onboarding; shared hosts use the default identity below.

{
  config,
  lib,
  ...
}:

let
  cfg = config.dotfiles.sshIdentity;

  homeManagerUsers = lib.attrNames config.home-manager.users;
  firstUser = if homeManagerUsers != [ ] then lib.head homeManagerUsers else "root";

  makeUserRules =
    username:
    lib.flatten [
      "d /home/${username}/.ssh 0700 ${username} users -"
      (lib.optional (config.sops.secrets ? ssh-private-key) "L+ /home/${username}/.ssh/id_ed25519 - - - - ${config.sops.secrets.ssh-private-key.path}")
      "C /home/${username}/.ssh/id_ed25519.pub 0644 ${username} users - ${toString cfg.publicKeyPath}"
    ];
in
{
  options.dotfiles.sshIdentity = {
    privateKeySopsKey = lib.mkOption {
      type = lib.types.str;
      default = "ssh_private_key";
      description = "Key name inside the sops file for the outbound SSH private key.";
    };

    publicKeyPath = lib.mkOption {
      type = lib.types.path;
      default = ../../secrets/id_ed25519.pub;
      description = "Plaintext public key deployed as ~/.ssh/id_ed25519.pub.";
    };

    sopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional sops file for the SSH private key. Null uses sops.defaultSopsFile.";
    };

    authorizedKeyFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ../../secrets/id_ed25519.pub ];
      description = "Public keys allowed to SSH in (login). Defaults to the shared key so existing machines keep access.";
    };
  };

  config = {
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      secrets = {
        ssh-private-key = {
          key = cfg.privateKeySopsKey;
          path = "/run/secrets/ssh-private-key";
          owner = firstUser;
          group = "users";
          mode = "0600";
        }
        // lib.optionalAttrs (cfg.sopsFile != null) {
          sopsFile = cfg.sopsFile;
        };
      };
    };

    systemd.tmpfiles.rules = lib.flatten (map makeUserRules homeManagerUsers);

    users.users = lib.listToAttrs (
      map (
        username:
        lib.nameValuePair username {
          openssh.authorizedKeys.keyFiles = cfg.authorizedKeyFiles;
        }
      ) homeManagerUsers
    );
  };
}

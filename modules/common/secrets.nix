# Secrets configuration and deployment for sops-nix
# This file handles both sops configuration and deploying secrets to users
#
# IMPORTANT: Only the private key is encrypted. The public key is stored as plain text.
# See docs/travis.md for host-key onboarding; shared hosts use the default identity below.

{
  config,
  lib,
  pkgs,
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
      "L+ /home/${username}/.ssh/id_ed25519.pub - - - - ${toString cfg.publicKeyPath}"
    ];

  # sops looks at ~/.config/sops/age/keys.txt (and root's, under sudo).
  # The identity is the SSH host key, same as sops.age.sshKeyPaths.
  installSopsAgeIdentity = pkgs.writeShellScript "install-sops-age-identity" ''
    set -euo pipefail
    host_key=/etc/ssh/ssh_host_ed25519_key
    if [[ ! -r "$host_key" ]]; then
      echo "sops age identity: $host_key not readable yet, skipping" >&2
      exit 0
    fi
    key="$(${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i "$host_key")"
    install_one() {
      local dest="$1" owner="$2" group="$3"
      mkdir -p -- "$(dirname "$dest")"
      printf '%s\n' "$key" > "$dest"
      chown "$owner:$group" "$dest"
      chmod 600 "$dest"
    }
    install_one /root/.config/sops/age/keys.txt root root
    ${lib.concatMapStrings (username: ''
      if [[ -d /home/${username} ]]; then
        install_one /home/${username}/.config/sops/age/keys.txt ${username} users
      fi
    '') homeManagerUsers}
  '';
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
    environment.systemPackages = with pkgs; [
      sops
      jq
      ssh-to-age
    ];

    # Immediate install on switch, and again at boot after host keys exist.
    system.activationScripts.sops-age-identity = {
      deps = [ "users" ];
      text = ''
        ${installSopsAgeIdentity}
      '';
    };
    systemd.services.sops-age-identity = {
      description = "Install sops age identity from the SSH host key";
      wantedBy = [ "multi-user.target" ];
      after = [ "sshd-keygen.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = "exec ${installSopsAgeIdentity}";
    };

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

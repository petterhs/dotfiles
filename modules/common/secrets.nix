# Secrets configuration and deployment for sops-nix
# This file handles both sops configuration and deploying secrets to users
#
# IMPORTANT: Only the private key is encrypted. The public key is stored as plain text.
# See SECRETS_SETUP.md for detailed instructions

{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Get usernames from home-manager users
  homeManagerUsers = lib.attrNames config.home-manager.users;

  # Get the first home-manager user (or fallback to a system user)
  # This is used as the owner for the sops secret file
  # The actual per-aser access is handled via symlinks
  firstUser = if homeManagerUsers != [] then lib.head homeManagerUsers else "root";

  # Path to the plain text SSH public key (safe to commit to git)
  sshPublicKeyPath = ../../secrets/id_ed25519.pub;

  # Helper to create tmpfiles rules for a user
  makeUserRules =
    username:
    lib.flatten [
      # Create SSH directory
      "d /home/${username}/.ssh 0700 ${username} users -"
      # Symlink private key (decrypted from sops)
      (lib.optional (
        config.sops.secrets ? ssh-private-key
      ) "L+ /home/${username}/.ssh/id_ed25519 - - - - ${config.sops.secrets.ssh-private-key.path}")
      # Copy public key (plain text, safe to read during evaluation)
      "C /home/${username}/.ssh/id_ed25519.pub 0644 ${username} users - ${toString sshPublicKeyPath}"
    ];
in
{
  # Enable sops and configure secrets
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    # Use SSH host keys for decryption - each host uses its own host key
    # This is simpler and more secure than dedicated age keys
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Only encrypt the private key - public key is stored as plain text
    secrets = {
      # SSH private key - same key on all hosts (ENCRYPTED)
      ssh-private-key = {
        key = "ssh_private_key";  # Key name in secrets.yaml
        path = "/run/secrets/ssh-private-key";
        owner = firstUser;  # Will be adjusted per user via symlinks
        group = "users";
        mode = "0600";  # Read/write for owner only
        # Will be symlinked to ~/.ssh/id_ed25519 by tmpfiles rules below
      };
    };
  };

  # Ensure directories exist and deploy keys to user home directories
  systemd.tmpfiles.rules = lib.flatten (map makeUserRules homeManagerUsers);

  # Add SSH public key to authorized_keys for passwordless SSH
  # Using keyFiles to point directly to the plain text public key file
  users.users = lib.mkMerge (
    [
      (lib.listToAttrs (
        map
          (username:
            lib.nameValuePair username {
              openssh.authorizedKeys.keyFiles = [ sshPublicKeyPath ];
            })
          homeManagerUsers
      ))
    ]
  );
}

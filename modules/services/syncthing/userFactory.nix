# Factory function for provisioning folder sections for a given user
{lib, ...}: {
  flake.factory.syncthingUser = let
    # Helper function for capitalization
    capitalize = s:
      if s == ""
      then ""
      else (lib.toUpper (builtins.substring 0 1 s)) + (builtins.substring 1 (builtins.stringLength s) s);
  in
    {
      user,
      alias ? user,
      rootDir ? (capitalize alias),
      group ? "users",
      ...
    }: {
      # Register our users' main directory for nixos-level syncthing
      # Provision appropriate file ownership too; user if user exists, syncthing if not
      nixos.syncthing = {
        config,
        lib,
        ...
      }: let
        syncUser = config.services.syncthing.user;
        syncGroup = config.users.users.${syncUser}.group;
        syncDir = "${config.services.syncthing.dataDir}";
        targetDir = "${syncDir}/${config.local.syncthing.userDirs.${user} or rootDir}";
      in {
        config = lib.mkMerge [
          {
            # Set systemwide target setting
            local.syncthing.userDirs.${user} = rootDir;
            # Provision permissions for the user container directory
            systemd.tmpfiles.settings."30-syncthing-${user}" = {
              "${targetDir}" = {
                d = {
                  mode = "0750";
                };
              };
            };
          }
          (
            # The user is present in the system; provision ownership to user
            lib.mkIf (config.users.users.${user}.enable == true) {
              systemd.tmpfiles.settings."30-syncthing-${user}" = {
                # Let the real user traverse the Syncthing home
                "${syncDir}" = {
                  "a+".argument = "u:${user}:--x";
                };
                # The user's container directory in syncthing home
                # Owned by the user
                "${targetDir}" = {
                  d = {
                    inherit group user;
                  };
                  # Allow syncthing access this user-owned subtree.
                  "A+".argument = "u:${syncUser}:rwX,m::rwX";
                  "a+".argument = "u:${syncUser}:rwx,d:u:${syncUser}:rwx,m::rwx,d:m::rwx";
                };
              };
            }
          )
          (
            # The user is not present in the system; provision ownership to syncthing
            lib.mkIf (config.users.users.${user}.enable == false) {
              systemd.tmpfiles.settings."30-syncthing-${user}" = {
                # Since owner is not present in the system, let syncthing own it
                "${targetDir}" = {
                  d = {
                    user = syncUser;
                    group = syncGroup;
                  };
                };
              };
            }
          )
        ];
      };
    };
}

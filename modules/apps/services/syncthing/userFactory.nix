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
      # Register our users' main directory for nixos syncthing
      nixos.syncthing = {...}: {
        local.syncthing.userDirs.${user} = rootDir;
      };

      # Users' setup of their own syncthing folder
      nixos."${user}" = {config, ...}: let
        syncUser = config.services.syncthing.user;
        syncDir = "${config.services.syncthing.dataDir}";
        targetDir = "${syncDir}/${config.local.syncthing.userDirs.${user} or rootDir}";
      in {
        systemd.tmpfiles.settings."30-syncthing-${user}" = {
          # Let the real user traverse the Syncthing home
          "${syncDir}" = {
            "a+".argument = "u:${user}:--x";
          };
          # The user's container directory in syncthing home
          "${targetDir}" = {
            d = {
              inherit group user;
              mode = "0750";
            };
            # Allow syncthing access this user-owned subtree.
            "a+".argument = "u:${syncUser}:rwx,d:u:${syncUser}:rwx,m::rwx,d:m::rwx";
          };
        };
      };
    };
}

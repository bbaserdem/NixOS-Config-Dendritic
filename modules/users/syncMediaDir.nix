# Factory function for registering sync directories with syncthing, and xdg directories
# Output of this should be set to flake.modules
# If there is no syncthing, completely fine, only sets XDG for user
{lib, ...}: {
  flake.factory.syncMediaDir = let
    capitalize = s:
      if s == ""
      then ""
      else (lib.toUpper (builtins.substring 0 1 s)) + (builtins.substring 1 (builtins.stringLength s) s);
  in
    {
      userDir,
      userDirPretty ? (capitalize userDir),
      userDirDarwin ? userDirPretty,
      nameUser,
      aliasUser ? nameUser,
      nameUserPretty ? (capitalize aliasUser),
      syncName ? "${aliasUser}-${userDir}",
      sharedHosts ? [],
      perHost ? {},
      ...
    }: {
      # Modules for setting up syncthing and user audio dir

      # Folder definitions for our user to share
      generic.syncthing = {
        lib,
        config,
        ...
      }: let
        hostName = config.networking.hostName;
      in {
        config = lib.mkMerge [
          {
            services.syncthing.settings.folders."${syncName}" = {
              enable = lib.mkOverride 1400 false;
              label = "${nameUserPretty} ${userDirPretty}";
              id = "${nameUserPretty}_${userDirPretty}";
              type = "sendreceive";
              devices = lib.filter (device: device != hostName) sharedHosts;
              versioning = {
                type = "trashcan";
                params = {cleanoutDays = "60";};
              };
            };
          }
          (
            lib.mkIf (lib.elem hostName sharedHosts) {
              services.syncthing.settings.folders."${syncName}" =
                {
                  enable = lib.mkDefault true;
                }
                // (lib.attrByPath [hostName] {} perHost);
            }
          )
        ];
      };

      # Folder location for darwin and hm-standalone settings
      homeManager.syncthing = {pkgs, ...}: {
        services.syncthing.settings.folders."${syncName}".path =
          if pkgs.stdenv.hostPlatform.isDarwin
          then "~/${userDirDarwin}"
          else "~/${userDirPretty}";
      };

      # Folder location for nixos settings
      nixos.syncthing = {
        config,
        lib,
        ...
      }: let
        targetDir = "${config.syncthing.dataDir}/${nameUserPretty}/${userDirPretty}";
      in {
        config = lib.mkMerge [
          {
            # Sync to the directory
            services.syncthing.settings.folders."${syncName}".path = targetDir;
          }
          (
            lib.mkIf (lib.hasAttrByPath ["users" "users" "${nameUser}"] config) {
              # Drop a symlink if user is enabled
              home-manager.users."${nameUser}".imports = [
                ({config, ...}: {
                  home.file."${userDirPretty}".source = config.lib.file.mkOutOfStoreSymlink "${targetDir}";
                })
              ];
            }
          )
        ];
      };

      # XDG dir setting for the user
      homeManager."${nameUser}" = {
        lib,
        pkgs,
        config,
        ...
      }: {
        config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          # XDG directory setting
          xdg.userDirs."${userDir}" = lib.mkOverride 1100 "${config.home.homeDirectory}/${userDirPretty}";
        };
      };
    };
}

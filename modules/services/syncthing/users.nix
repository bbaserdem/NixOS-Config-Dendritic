# Create syncthing folder configuration users to share xdg files
{
  config,
  lib,
  ...
}: let
  # Shortcuts
  cfg = config.localConfig.syncthing;
  users = cfg.users;
  darwinDirs = {
    desktop = "Desktop";
    documents = "Documents";
    download = "Downloads";
    music = "Music";
    pictures = "Pictures";
    projects = "Projects";
    templates = "Templates";
    videos = "Movies";
  };

  # Functions
  capitalize = s:
    if s == ""
    then ""
    else (lib.toUpper (builtins.substring 0 1 s)) + (builtins.substring 1 (builtins.stringLength s) s);

  # Ignore
  mkIgnoreText = hostName: xdgCfg: ''
    ${cfg.ignore.global}
    ${cfg.ignore.hosts.${hostName} or ""}
    ${xdgCfg.ignore.global}
    ${xdgCfg.ignore.hosts.${hostName} or ""}
  '';
  # Joint folder-id
  mkFolderName = user: xdgDir: "${user}-${xdgDir}";
  # Pre-processing; unfold everything
  flattenXdgFolders =
    users
    |> lib.mapAttrsToList (user: userCfg:
      userCfg.xdg
      |> lib.mapAttrsToList (xdgDir: xdgCfg: {
        name = mkFolderName user xdgDir;
        value = {
          inherit user xdgDir;
          inherit (xdgCfg) hosts ignore;
          label = "${capitalize user} ${capitalize xdgDir}";
        };
      }))
    |> lib.flatten
    |> builtins.listToAttrs;
in {
  config.flake.modules = {
    # Folder generation modules

    # Dispatch folder to main syncthing configuration
    generic.syncthing = {lib, ...}: {
      services.syncthing.settings.folders =
        flattenXdgFolders
        |> lib.mapAttrs' (name: folder: {
          inherit name;
          value = {
            enable = lib.mkDefault false;
            path = lib.mkOverride 1400 "~/Syncthing/${name}";
            devices = lib.mkDefault folder.hosts;
            id = name;
            label = lib.mkDefault folder.label;
          };
        });
    };

    # Home-Manager; create folders' path
    homeManager.syncthing = {
      config,
      pkgs,
      lib,
      options,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["networking" "hostName"] options) (let
        hostName = config.networking.hostName;
        userName = config.home.username;
        enabledFolders =
          flattenXdgFolders
          |> lib.filterAttrs (
            _: folder:
              folder.user == userName && lib.elem hostName folder.hosts
          );
        xdgPath = xdgDir:
          if pkgs.stdenv.hostPlatform.isDarwin
          then "${config.home.homeDirectory}/${darwinDirs.${xdgDir}}"
          else config.xdg.userDirs.${xdgDir};
        relativeToHome = path:
          if lib.hasPrefix "${config.home.homeDirectory}/" path
          then lib.removePrefix "${config.home.homeDirectory}/" path
          else if lib.hasPrefix "~/" path
          then lib.removePrefix "~/" path
          else throw "XDG Syncthing path '${path}' not under HOME; can't manage .stignore file";
      in {
        # Enable this users' folders in this setting
        services.syncthing.settings.folders =
          enabledFolders
          |> lib.mapAttrs' (name: folder: {
            inherit name;
            value = {
              enable = true;
              path = xdgPath folder.xdgDir;
              devices = lib.filter (host: host != hostName) folder.hosts;
            };
          });
        # Drop stignore files
        home.file = lib.mkIf config.services.syncthing.enable (
          enabledFolders
          |> lib.mapAttrs' (name: folder: {
            name = "${relativeToHome (xdgPath folder.xdgDir)}/.stignore";
            value.text = mkIgnoreText hostName folder;
          })
        );
      });
    };

    # Nixos; create folder's path and bind mount
    nixos.syncthing = {
      config,
      lib,
      options,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["home-manager"] options) (let
        hostName = config.networking.hostName;
        dataDir = config.services.syncthing.dataDir;
        syncUser = config.services.syncthing.user;
        syncGroup = config.services.syncthing.group;
        # Enabled folders
        enabledFolders = lib.filterAttrs (_: folder: lib.elem hostName folder.hosts) flattenXdgFolders;
        userEnabled = user: config.users.users.${user}.enable or false;
        userHome = user: config.users.users.${user}.home;
        userGroup = user: config.users.users.${user}.group;
        # Path resolvel
        userXdgPath = user: xdgDir: config.home-manager.users.${user}.xdg.userDirs.${xdgDir};
        mkPath = folder: "${dataDir}/${capitalize folder.user}/${capitalize folder.xdgDir}";
      in {
        services.syncthing.settings.folders =
          enabledFolders
          |> lib.mapAttrs' (name: folder: {
            inherit name;
            value = {
              enable = true;
              path = mkPath folder;
              devices = lib.filter (host: host != hostName) folder.hosts;
              ignorePatterns = lib.splitString "\n" (mkIgnoreText hostName folder);
            };
          });
        # Provision folder permissions
        systemd.tmpfiles.settings =
          enabledFolders
          |> lib.mapAttrs' (name: folder: {
            name = "35-syncthing-xdg-${name}";
            value =
              if userEnabled folder.user
              then {
                "${userXdgPath folder.user folder.xdgDir}" = {
                  d = {
                    user = folder.user;
                    group = userGroup folder.user;
                    mode = "0750";
                  };
                  "A+".argument = "u:${syncUser}:rwX,m::rwX";
                  "a+".argument = "u:${syncUser}:rwx,d:u:${syncUser}:rwx,m::rwx,d:m::rwx";
                };
                "${mkPath folder}".d = {
                  user = folder.user;
                  group = userGroup folder.user;
                  mode = "0750";
                };
              }
              else {
                "${mkPath folder}".d = {
                  user = syncUser;
                  group = syncGroup;
                  mode = "0750";
                };
              };
          });
        # Provision bind mounts
        fileSystems =
          enabledFolders
          |> lib.filterAttrs (_: folder: userEnabled folder.user)
          |> lib.mapAttrs' (name: folder: {
            name = mkPath folder;
            value = {
              device = userXdgPath folder.user folder.xdgDir;
              fsType = "none";
              options = ["bind" "nofail"];
              depends = [(userHome folder.user)];
            };
          });
      });
    };
  };
}

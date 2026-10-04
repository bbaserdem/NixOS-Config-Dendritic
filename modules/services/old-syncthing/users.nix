# Create syncthing folder configuration users to share xdg files
{
  inputs,
  config,
  lib,
  ...
}: let
  # Shortcuts
  cfgSync = config.localConfig.syncthing;
  cfgUsers = config.localConfig.users;
  users = cfgSync.users;
  mediaRoot = cfgSync.mediaRoot;
  registeredHost = host: (cfgSync.hosts.${host}.id or "") != "";
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
  capitalize = inputs.self.lib.capitalize;

  # Ignore
  mkIgnoreText = hostName: xdgCfg: ''
    ${cfgSync.ignore.global}
    ${cfgSync.ignore.hosts.${hostName} or ""}
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
        # Resolve non-xdg directories (localConfig extraDirs) relative to HOME
        extraRel = xdgDir:
          cfgUsers.${userName}.extraDirs.${xdgDir}
          or (throw "localConfig.users.${userName}.extraDirs.${xdgDir} is needed for syncthing module");
        xdgPath = xdgDir:
          if pkgs.stdenv.hostPlatform.isDarwin
          then "${config.home.homeDirectory}/${darwinDirs.${xdgDir} or (extraRel xdgDir)}"
          else config.xdg.userDirs.${xdgDir} or "${config.home.homeDirectory}/${extraRel xdgDir}";
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
              devices = lib.filter (host: (host != hostName) && (registeredHost host)) folder.hosts;
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
      config =
        lib.optionalAttrs (
          (lib.hasAttrByPath ["home-manager"] options)
          && (lib.hasAttrByPath ["local" "hm" "users"] options)
        ) (let
          hostName = config.networking.hostName;
          syncUser = config.services.syncthing.user;

          # Enabled folders
          enabledFolders = lib.filterAttrs (_: folder: lib.elem hostName folder.hosts) flattenXdgFolders;
          userEnabled = user: config.local.hm.users.${user} or false;

          # Path resolver
          userHome = user: cfgUsers.${user}.home.linux;
          userXdgRelPath = user: xdgDir: (
            cfgUsers.${user}.xdgDirs.${xdgDir}
            or cfgUsers.${user}.extraDirs.${xdgDir}
            or (throw "localConfig.users.${user}.xdgDirs.${xdgDir} is needed for syncthing module")
          );
          userXdgPath = user: xdgDir: "${userHome user}/${userXdgRelPath user xdgDir}";
          mkPathUser = user: "${mediaRoot}/${capitalize user}";
          mkPath = folder: "${mediaRoot}/${capitalize folder.user}/${capitalize folder.xdgDir}";

          # Walk from the users' home to the bind target;
          # every element except the target itself is a parent that must
          # exist with correct ownership before the bind mount lands
          # (tmpfiles auto-created parents would be root:root)
          targetWalk = folder: inputs.self.lib.walkToDir (userHome folder.user) (userXdgPath folder.user folder.xdgDir);
          targetParents = folder: let
            walk = targetWalk folder;
          in
            if walk == []
            then []
            else lib.init walk;
          mkParentRules = user: parents:
            parents
            |> map (path:
              lib.nameValuePair path {
                d = {
                  user = user;
                  group = "users";
                  mode = "0750";
                };
              })
            |> lib.listToAttrs;
        in {
          services.syncthing.settings.folders =
            enabledFolders
            |> lib.mapAttrs' (name: folder: {
              inherit name;
              value = {
                enable = true;
                path = mkPath folder;
                devices = lib.filter (host: (host != hostName) && (registeredHost host)) folder.hosts;
                ignorePatterns = lib.splitString "\n" (mkIgnoreText hostName folder);
                # Never apply or propagate permission bits; content is
                # created as 0660/0770 via the service UMask, and setgid
                # dirs keep group "users" inherited
                ignorePerms = true;
              };
            });

          # Provision folder permissions
          systemd.tmpfiles.settings = lib.mkMerge (
            (
              # Namespace dirs; /home/media/<User>
              # Group "users" carries syncthing's access (traversal only);
              # setgid so anything created inside inherits the group
              enabledFolders
              |> lib.mapAttrsToList (_: folder: folder.user)
              |> lib.unique
              |> map (
                user: {
                  "34-syncthing-namespace-${user}"."${mkPathUser user}".d = {
                    user =
                      if (userEnabled user)
                      then user
                      else syncUser;
                    group = "users";
                    mode = "2750";
                  };
                }
              )
            )
            ++ (
              # Home-side parent hierarchies for nested bind targets
              # (xdgDirs and extraDirs entries alike, e.g. Shared/Android).
              # One shared key per user; identical entries contributed by
              # sibling folders or other modules merge at eval time into
              # a single tmpfiles line. Sorts before 35-* targets.
              enabledFolders
              |> lib.filterAttrs (_: folder: userEnabled folder.user)
              |> lib.mapAttrsToList (_: folder: {
                "34-home-dirs-${folder.user}" = mkParentRules folder.user (targetParents folder);
              })
            )
            ++ [
              (
                # XDG folders; real location and bind target
                enabledFolders
                |> lib.mapAttrs' (name: folder: {
                  name = "35-syncthing-xdg-${name}";
                  value =
                    {
                      # Real location under /home/media; group-writable
                      # for syncthing, setgid for group inheritance
                      "${mkPath folder}".d = {
                        user =
                          if (userEnabled folder.user)
                          then folder.user
                          else syncUser;
                        group = "users";
                        mode = "2770";
                      };
                    }
                    // lib.optionalAttrs (userEnabled folder.user) {
                      # Bind target in the users' home
                      # Deliberately identical to the media-side rul;
                      # Once mounted, bboth paths alias the same inode,
                      # and tmpfiles re-runs on every activation with mounts active
                      "${userXdgPath folder.user folder.xdgDir}".d = {
                        user = folder.user;
                        group = "users";
                        mode = "2770";
                      };
                    };
                })
              )
            ]
          );
          # Provision bind mounts
          fileSystems =
            enabledFolders
            |> lib.filterAttrs (_: folder: userEnabled folder.user)
            |> lib.mapAttrs' (name: folder: {
              name = userXdgPath folder.user folder.xdgDir;
              value = {
                device = mkPath folder;
                fsType = "none";
                options = [
                  "bind"
                  "nofail"
                  "x-systemd.after=systemd-tmpfiles-setup.service"
                ];
                depends = [
                  mediaRoot
                  (userHome folder.user)
                ];
              };
            });
        });
    };
  };
}

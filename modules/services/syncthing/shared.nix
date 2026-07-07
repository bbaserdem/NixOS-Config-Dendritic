# Syncthing shared folder
{
  inputs,
  config,
  lib,
  ...
}: let
  # Shortcuts
  cfgSync = config.localConfig.syncthing;
  cfgUsers = config.localConfig.users;
  shared = cfgSync.shared;
  mediaRoot = cfgSync.mediaRoot;

  # Home-relative location of the user-facing directory
  sharedRel = user:
    cfgUsers.${user}.extraDirs.sharedSyncthing
    or "Shared/Syncthing";
  registeredHost = host: (cfgSync.hosts.${host}.id or "") != "";

  # Ignore
  mkIgnoreText = hostName: ''
    ${cfgSync.ignore.global}
    ${cfgSync.ignore.hosts.${hostName} or ""}
    ${shared.ignore.global}
    ${shared.ignore.hosts.${hostName} or ""}
  '';
in {
  config.flake.modules = lib.mkIf shared.enable {
    # Register folder in the global configuration
    generic.syncthing = {lib, ...}: {
      services.syncthing.settings.folders.shared = {
        enable = lib.mkDefault false;
        path = lib.mkOverride 1400 "~/Syncthing/Shared";
        devices = lib.mkDefault shared.hosts;
        id = "shared";
        label = lib.mkDefault "Shared";
      };
    };

    # Home-Manager; covers darwin (dispatched to mainUser) and standalone
    # contexts. Syncthing runs per-user here, so the folder lives directly
    # at the target path; no media root and no bind mount
    homeManager.syncthing = {
      config,
      lib,
      options,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["networking" "hostName"] options) (let
        hostName = config.networking.hostName;
        userName = config.home.username;
        sharedPath = "${config.home.homeDirectory}/${sharedRel userName}";
      in
        lib.mkIf (lib.elem hostName shared.hosts) {
          services.syncthing.settings.folders.shared = {
            enable = true;
            path = sharedPath;
            devices = lib.filter (host: (host != hostName) && (registeredHost host)) shared.hosts;
          };
          # Drop stignore; as a side effect home-manager creates the
          # folder root, so syncthing can place its marker on first start
          home.file = lib.mkIf config.services.syncthing.enable {
            "${sharedRel userName}/.stignore".text = mkIgnoreText hostName;
          };
        });
    };

    # NixOS; single system daemon, folder under mediaRoot, bind mounted
    # into every syncthing-enabled users' home
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
          sharedPath = "${mediaRoot}/Shared";

          # Bound users; syncthing-enabled and present on this host
          userEnabled = user: config.local.hm.users.${user} or false;
          boundUsers =
            cfgSync.users
            |> lib.filterAttrs (user: userCfg: userCfg.enable && userEnabled user)
            |> lib.attrNames;

          # Path resolver
          userHome = user: cfgUsers.${user}.home.linux;
          userGroup = user: cfgUsers.${user}.group;
          target = user: "${userHome user}/${sharedRel user}";

          # Walk from the users' home to the bind target;
          # every element except the target itself is a parent that must
          # exist user-owned before the bind mount lands
          targetParents = user: let
            walk = inputs.self.lib.walkToDir (userHome user) (target user);
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
                  group = userGroup user;
                  mode = "0750";
                };
              })
            |> lib.listToAttrs;
        in
          lib.mkIf (lib.elem hostName shared.hosts) {
            services.syncthing.settings.folders.shared = {
              enable = true;
              path = sharedPath;
              devices = lib.filter (host: (host != hostName) && (registeredHost host)) shared.hosts;
              ignorePatterns = lib.splitString "\n" (mkIgnoreText hostName);
              # Content is created 0660/0770 via the service UMask;
              # setgid keeps group "users" inherited
              ignorePerms = true;
            };

            systemd.tmpfiles.settings = lib.mkMerge (
              [
                {
                  # Real location; owner is nominal, group carries access.
                  # The fixer normalizes group and modes only, never owner
                  "36-syncthing-shared"."${sharedPath}".d = {
                    user = syncUser;
                    group = "users";
                    mode = "2770";
                  };
                }
              ]
              ++ (
                boundUsers
                |> map (user: {
                  # Parent hierarchy; same key as the xdg module so
                  # identical entries merge at eval time
                  "34-home-dirs-${user}" = mkParentRules user (targetParents user);
                  # Bind target stub; identical to the source rule, since
                  # once mounted every user's target aliases the same
                  # inode and tmpfiles re-runs on every activation
                  "36-syncthing-shared-${user}"."${target user}".d = {
                    user = syncUser;
                    group = "users";
                    mode = "2770";
                  };
                })
              )
            );

            # Bind the shared tree into each bound users' home
            fileSystems =
              boundUsers
              |> map (user: {
                name = target user;
                value = {
                  device = sharedPath;
                  fsType = "none";
                  options = [
                    "bind"
                    "nofail"
                    "x-systemd.after=systemd-tmpfiles-setup.service"
                  ];
                  depends = [
                    mediaRoot
                    (userHome user)
                  ];
                };
              })
              |> builtins.listToAttrs;
          });
    };
  };
}

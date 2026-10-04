# Syncthing media tree; root provisioning and periodic normalization
# of ownership and permissions under the media root
{
  inputs,
  config,
  ...
}: let
  # Shortcuts
  cfgSync = config.localConfig.syncthing;
  mediaRoot = cfgSync.mediaRoot;
  shared = cfgSync.shared;

  # Functions
  capitalize = inputs.self.lib.capitalize;
in {
  config.flake.modules.nixos.syncthing = {
    config,
    lib,
    pkgs,
    options,
    ...
  }: {
    config = lib.optionalAttrs (lib.hasAttrByPath ["local" "hm" "users"] options) (let
      hostName = config.networking.hostName;
      userEnabled = user: config.local.hm.users.${user} or false;
      ownerExists = owner:
        (owner != null)
        && ((config.users.users.${owner}.enable or false) == true);

      # User namespaces; ownership enforced towards the user
      userTargets =
        cfgSync.users
        |> lib.filterAttrs (
          user: userCfg:
            userCfg.enable
            && (userEnabled user)
            && (
              userCfg.xdg
              |> lib.attrValues
              |> lib.any (dirCfg: lib.elem hostName dirCfg.hosts)
            )
        )
        |> lib.mapAttrsToList (user: _: {
          path = "${mediaRoot}/${capitalize user}";
          owner = user;
        });

      # Owned service folders under the media root; ownership enforced
      # towards the owner. Folders with a systemPath are excluded, their
      # trees belong to the declaring service module
      folderTargets =
        cfgSync.folders
        |> lib.filterAttrs (
          _: folder:
            (lib.elem hostName folder.hosts)
            && (folder.systemPath == null)
            && (ownerExists folder.owner)
        )
        |> lib.mapAttrsToList (name: folder: {
          path = "${mediaRoot}/${capitalize name}";
          owner = folder.owner;
        });

      ownerTargets = userTargets ++ folderTargets;

      # Shared folder; multiple users write here, so only group and
      # modes are normalized, ownership stays with whoever created it
      sharedTargets =
        lib.optionals
        (shared.enable && lib.elem hostName shared.hosts)
        ["${mediaRoot}/Shared"];

      # Normalizers; all predicates are conditional so entries already
      # in the desired state are never touched (no ctime churn)
      mkModeFix = path: ''
        # Directories; setgid keeps group "users" inherited.
        # The tree root is skipped, tmpfiles owns its mode
        find ${lib.escapeShellArg path} -xdev -mindepth 1 -type d \
          ! -perm 2770 -exec chmod 2770 {} +
        # Files; 0770 for executables, 0660 otherwise
        find ${lib.escapeShellArg path} -xdev -type f -perm /0111 \
          ! -perm 0770 -exec chmod 0770 {} +
        find ${lib.escapeShellArg path} -xdev -type f ! -perm /0111 \
          ! -perm 0660 -exec chmod 0660 {} +
      '';
      mkOwnerFix = target: ''
        if [ -d ${lib.escapeShellArg target.path} ]; then
          # Ownership first; chown clears setgid on files, modes are
          # repaired right after
          find ${lib.escapeShellArg target.path} -xdev \
            \( ! -user ${target.owner} -o ! -group users \) \
            -exec chown -h ${target.owner}:users {} +
          ${mkModeFix target.path}
        fi
      '';
      mkGroupFix = path: ''
        if [ -d ${lib.escapeShellArg path} ]; then
          find ${lib.escapeShellArg path} -xdev ! -group users \
            -exec chgrp -h users {} +
          ${mkModeFix path}
        fi
      '';

      haveTargets = (ownerTargets != []) || (sharedTargets != []);
    in {
      # The media root itself; nothing writes here at runtime, all
      # direct children are provisioned by tmpfiles of other modules
      systemd.tmpfiles.settings."33-media-root"."${mediaRoot}".d = {
        user = "root";
        group = "root";
        mode = "0755";
      };

      # Periodic normalization pass
      systemd.services."syncthing-media-permissions" = lib.mkIf haveTargets {
        description = "Normalize ownership and permissions under ${mediaRoot}";
        path = [pkgs.coreutils pkgs.findutils];
        serviceConfig = {
          Type = "oneshot";
          Nice = 19;
          IOSchedulingClass = "idle";
          # Runs as root; confine writes to the media tree
          ProtectSystem = "strict";
          ReadWritePaths = [mediaRoot];
        };
        script = lib.concatStringsSep "\n" (
          (ownerTargets |> map mkOwnerFix)
          ++ (sharedTargets |> map mkGroupFix)
        );
      };

      systemd.timers."syncthing-media-permissions" = lib.mkIf haveTargets {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "10min";
          OnUnitActiveSec = "15min";
          RandomizedDelaySec = "2min";
        };
      };
    });
  };
}

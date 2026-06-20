# SSH permissions healing for each user.
{
  config,
  lib,
  ...
}: let
  users = config.localConfig.users;
in {
  options = {
    localConfig.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.sshSetup = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to dispatch SSH and SOPS permissions.";
        };
      });
    };
  };

  config = {
    flake.modules.nixos =
      users
      |> lib.filterAttrs (
        user: userCfg:
          (userCfg.normalUser or true) && (userCfg.sshSetup or false)
      )
      |> lib.mapAttrs' (
        user: userCfg: (lib.nameValuePair user (
          {...}: let
            home = userCfg.home.linux;
            group = userCfg.group;
          in {
            systemd.tmpfiles.settings."12-user-key-permissions-${user}" = {
              "${home}/.ssh".d = {
                inherit user group;
                mode = "0700";
              };
              "${home}/.ssh/*".z = {
                inherit user group;
                mode = "0600";
              };
              "${home}/.config/sops".d = {
                inherit user group;
                mode = "0700";
              };
              "${home}/.config/sops/age".d = {
                inherit user group;
                mode = "0700";
              };
              "${home}/.config/sops/age/keys.txt".z = {
                inherit user group;
                mode = "0600";
              };
            };
          }
        ))
      );
  };
}

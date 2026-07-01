# Network manager, user group dispatch
{
  config,
  lib,
  ...
}: let
  users = config.localConfig.users;
in {
  # Add flag for network manager users
  options = {
    localConfig.users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          {config, ...}: {
            options.nm-user = lib.mkOption {
              type = lib.types.bool;
              default = config.normalUser;
              defaultText = "config.normalUser";
              description = "Whether to add this user to NetworkManager groups.";
            };
          }
        )
      );
    };
  };

  config = {
    flake.modules.nixos =
      users
      |> lib.filterAttrs (_user: userCfg: userCfg.nm-user)
      |> lib.mapAttrs' (
        user: _userCfg:
          lib.nameValuePair user (
            {
              config,
              lib,
              ...
            }: {
              config = lib.mkIf (config.networking.networkmanager.enable) {
                users.users.${user}.extraGroups = [
                  "networkmanager"
                  "nm-openvpn"
                ];
              };
            }
          )
      );
  };
}

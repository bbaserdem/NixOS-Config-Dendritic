# Factory function for provisioning shared steam folder in linux
{
  config,
  lib,
  ...
}: let
  users = config.localConfig.users;
in {
  # Global config for users to define if they are going to use shared steam or not
  options = {
    localConfig.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.steamShare = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Flag to enable common asset sharing on steam.";
        };
      });
    };
  };

  config = {
    flake.modules = {
      # We install steam using brew in darwin
      darwin.steam = {...}: {
        homebrew.casks = [
          "steam"
          "steamcmd"
        ];
      };

      nixos =
        {
          # Steam setup in linux
          steam = {lib, ...}: {
            # Include hardware support for steam devices
            hardware.steam-hardware.enable = true;

            # Enable steam
            programs = {
              steam = {
                enable = true;
                extest.enable = true;
                dedicatedServer.openFirewall = true;
                # Enable a desktop session for steam
                gamescopeSession = {
                  enable = true;
                };
                # Enable network transfer of steamgames
                localNetworkGameTransfers = {
                  openFirewall = true;
                };
                # By default, don't enable remotePlay
                remotePlay = {
                  openFirewall = lib.mkOverride 1400 false;
                };
              };
              # Enable gamescope: steam session
              gamescope = {
                enable = true;
                capSysNice = true;
              };
            };
            # Create the games group
            users.groups.games.name = "games";
            # Create a shared directory for steam common data
            systemd.tmpfiles.settings."20-steam-common" = {
              "/opt/steam-common" = {
                d = {
                  user = "root";
                  group = "games";
                  mode = "2770";
                };
                "A+".argument = "g:games:rwX,m::rwX";
                "a+".argument = "d:g:games:rwx,d:m::rwx";
              };
            };
          };
        }
        // (
          users
          |> lib.filterAttrs (_user: userCfg: userCfg.steamShare or false)
          |> lib.mapAttrs' (user: userCfg: {
            name = user;
            value = {
              config,
              lib,
              ...
            }: let
              home = userCfg.home.linux;
              dispatchCfg = {
                d = {
                  user = user;
                  group = userCfg.group;
                  mode = "0750";
                };
              };
            in {
              config = lib.mkIf (config.programs.steam.enable or false) {
                # Add user to gaming group
                users.users.${user}.extraGroups = [
                  config.users.groups.games.name
                ];

                # Create the file hierarchy if non-existent
                systemd.tmpfiles.settings."25-steam-${user}" = {
                  "${home}/.local" = dispatchCfg;
                  "${home}/.local/share" = dispatchCfg;
                  "${home}/.local/share/Steam" = dispatchCfg;
                  "${home}/.local/share/Steam/steamapps" = dispatchCfg;
                  "${home}/.local/share/Steam/steamapps/common" = dispatchCfg;
                };

                # Create the bind mount to the common directory
                fileSystems."${home}/.local/share/Steam/steamapps/common" = {
                  device = "/opt/steam-common";
                  fsType = "none";
                  options = ["bind" "nofail"];
                  depends = [
                    "/home"
                    "${home}"
                    "/opt"
                    "/opt/steam-common"
                  ];
                };
              };
            };
          })
        );
    };
  };
}

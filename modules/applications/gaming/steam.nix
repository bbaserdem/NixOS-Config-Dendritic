# Steam configuration
{
  inputs,
  den,
  lib,
  flib,
  ...
}: {
  # Den wiring for steam
  den = {
    schema = {
      host = {
        includes = [
          den.aspects.applications._.steam.policies.steam-host-dispatch
        ];
        # New options under gaming metadata is steam
        imports = [
          ({config, ...}: {
            options = {
              gaming = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    # Steam settings
                    steam = lib.mkOption {
                      description = "Steam options";
                      default = {};
                      apply = cfg:
                        if (cfg.share && (config.class != "nixos"))
                        then
                          throw ''
                            Can only enable steam.share folder on nixos class host.
                            `${config.name}` is of class '${config.class}'.
                          ''
                        else cfg;
                      type = lib.types.submodule {
                        options = {
                          enable = lib.mkOption {
                            description = "Enable steam on this host";
                            default = false;
                            type = lib.types.bool;
                          };
                          share = lib.mkOption {
                            description = "Enable shared steam common folder mount";
                            default = false;
                            type = lib.types.bool;
                          };
                          shareDir = lib.mkOption {
                            description = "Path to the shared directory on this host";
                            default = "/opt/steam-common";
                            type = lib.types.str;
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          })
        ];
      };
      user = {
        includes = [
          den.aspects.applications._.steam.policies.steam-user-dispatch
        ];
      };
    };

    # Aspect for setting steam
    aspects.applications = {
      # Steam aspect
      provides.steam = {
        # Policies for dispatching
        # Enable steam for this user
        policies.steam-user-dispatch = {
          host,
          user,
          ...
        }:
          lib.optionals
          ( # This dispatch is conditional on the games being enabled on this host
            (builtins.elem "games" user.classes)
            && (host.gaming.enable)
            && (host.gaming.steam.enable)
          )
          (
            [
              # Set steam for this user
              (den.lib.policy.include den.aspects.applications._.steam._.to-users)
              # Create shared steam directory if set
            ]
            ++ (
              lib.optionals
              host.gaming.steam.share
              [
                (den.lib.policy.include den.aspects.applications._.steam._.steam-common._.to-users)
              ]
            )
          );
        # Enable steam share for this host
        policies.steam-host-dispatch = {host, ...}:
          lib.optionals
          ( # Enable if steam common is enabled and there is a gamer
            (host.class == "nixos")
            && (host.gaming.enable)
            && (host.gaming.steam.enable)
            && (host.gaming.steam.share)
            && (
              host.users
              |> builtins.attrValues
              |> lib.any (u: builtins.elem "games" u.classes)
            )
          )
          [
            # Set steam share folder for this host
            (den.lib.policy.include den.aspects.applications._.steam._.steam-common._.root-dir)
            # Create shared steam directory if set
          ];

        # Aspects for setting things up
        provides.to-users = {
          host,
          user,
        }: {
          name = "applications/steam(${user.userName}@${host.name})";
          # Set up steam with this parametric aspect
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.steam-settings
            ];
          };
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.steam-settings
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.steam-settings
            ];
          };
        };

        # Aspect that sets up shared directory and mounts
        provides.steam-common = {
          # Parametric module to create common mount directory
          includes = [
            den.aspects.applications._.steam._.steam-common._.root-dir
          ];
          provides.root-dir = {host}: {
            name = "applications/steam/steam-common/root-dir(@${host.name})";
            nixos = {config, ...}: {
              config = let
                grp =
                  if config.users.groups ? games
                  then "games"
                  else "users";
              in {
                # Create a shared directory for steam common data
                systemd.tmpfiles.settings."20-steam-common" = {
                  "${host.gaming.steam.shareDir}" = {
                    d = {
                      user = "root";
                      # TODO: This is conditional on games aspect; should be users?
                      group = grp;
                      mode = "2770";
                    };
                    # Everyone should be able to write here in games
                    "A+".argument = "g:${grp}:rwX,m::rwX";
                    "a+".argument = "d:g:${grp}:rwx,d:m::rwx";
                  };
                };
              };
            };
          };

          # Parametric module to setup users with the bind mounts
          provides.to-users = {
            host,
            user,
          }: {
            name = "applications/steam/steam-common(${user.userName}@${host.name})";
            nixos = {lib, ...}: let
              steamCommon = ".local/share/Steam/steamapps/common";
            in {
              # TODO: make this conditional to the user setting
              config = lib.mkIf true {
                # Create the file hierarchy
                systemd.tmpfiles.settings."25-steam-user-${user.userName}" =
                  "${user.homeDirectory}/${steamCommon}"
                  |> flib.walkToDir user.homeDirectory
                  |> builtins.map (dir:
                    lib.nameValuePair
                    "${dir}"
                    {
                      d = {
                        user = user.userName;
                        group = "users";
                        mode = "0750";
                      };
                    })
                  |> builtins.listToAttrs;
                # Create the bind mount to the common directory
                fileSystems."${user.homeDirectory}/${steamCommon}" = {
                  device = host.gaming.steam.shareDir;
                  fsType = "none";
                  options = [
                    "bind"
                    "nofail"
                    "x-systemd.after=systemd-tmpfiles-setup.service"
                  ];
                  depends = [
                    host.gaming.steam.shareDir
                    user.homeDirectory
                  ];
                };
              };
            };
          };
        };
      };
    };
  };

  # Modules for setting up steam
  flake.modules = {
    # We install steam using brew in darwin
    darwin.steam-settings = {...}: {
      key = "steam-settings#darwin";
      config = {
        homebrew.casks = [
          "steam"
          "steamcmd"
        ];
      };
    };
    # In nixos; we use the global steam module
    nixos.steam-settings = {lib, ...}: {
      key = "steam-settings#nixos";
      config = {
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
      };
    };
    # In home-manager, we set lutris steam to nixos steam if it's set
    homeManager.steam-settings = {
      pkgs,
      lib,
      ...
    } @ args: {
      key = "steam-settings#homeManager";
      config = lib.mkMerge [
        (
          lib.optionalAttrs (lib.hasAttrByPath ["osConfig"] args) (
            lib.mkIf (
              (pkgs.stdenv.hostPlatform.isLinux)
              && (args.osConfig.programs.steam.package != null)
            ) {
              programs.lutris.steamPackage = args.osConfig.programs.steam.package;
            }
          )
        )
      ];
    };
  };
}

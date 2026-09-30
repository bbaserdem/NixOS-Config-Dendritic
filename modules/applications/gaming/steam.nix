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
          den.aspects.gaming.policies.steam-host-dispatch
        ];
        # New options under gaming metadata for steam
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
                          remotePlay = lib.mkOption {
                            description = "Enable steam remote play from this host";
                            default = false;
                            type = lib.types.bool;
                          };
                          gamescope = lib.mkOption {
                            description = "Enable gamescope desktop session";
                            default = false;
                            type = lib.types.bool;
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
          den.aspects.gaming.policies.steam-user-dispatch
        ];
      };
    };

    # Aspect for setting steam
    aspects.gaming = {
      # Policies for dispatching
      policies.steam-host-dispatch = {host, ...}:
        lib.optionals
        (host.gaming.enable && host.gaming.steam.enable)
        (
          [
            (den.lib.policy.include den.aspects.gaming._.steam)
            (den.lib.policy.include den.aspects.gaming._.steam._.host-setup)
          ]
          ++ (
            lib.optional
            host.gaming.steam.gamescope
            (den.lib.policy.include den.aspects.gaming._.steam._.gamescope)
          )
          ++ (
            lib.optional
            (
              host.gaming.steam.share
              && (
                host.users
                |> builtins.attrValues
                |> lib.any (u: builtins.elem "games" u.classes)
              )
            )
            (den.lib.policy.include den.aspects.gaming._.steam._.share-host-setup)
          )
        );
      policies.steam-user-dispatch = {
        host,
        user,
        ...
      }:
        lib.optionals
        ( # This dispatch is conditional on the games being enabled on this host
          (builtins.elem "games" user.classes)
          && host.gaming.enable
          && host.gaming.steam.enable
        )
        (
          [(den.lib.policy.include den.aspects.gaming._.steam._.user-setup)]
          ++ (
            lib.optionals
            host.gaming.steam.share
            [
              (den.lib.policy.include den.aspects.gaming._.steam._.share-user-setup)
            ]
          )
        );

      provides.steam = {
        # TODO: Dispatch port settings through our quirk as well
        name = "gaming/steam";
        # Steam modules for system
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

        # Gamescope feature
        provides.gamescope = {
          name = "gaming/steam/gamescope";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.steam-gamescope
            ];
          };
        };
        # Host-specific configuration
        provides.host-setup = {host}: {
          name = "gaming/steam/host-setup(@${host.name})";
          nixos = {...}: {
            config = {
              programs.steam = {
                remotePlay.openFirewall = host.gaming.steam.remotePlay;
              };
            };
          };
        };

        # Host share setup
        provides.share-host-setup = {host}: {
          name = "gaming/steam/share-host-setup(@${host.name})";
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

        # Aspects for setting users
        provides.user-setup = {
          host,
          user,
        }: {
          name = "gaming/steam/user-setup(${user.userName}@${host.name})";
          # Set up steam with this parametric aspect
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.steam-settings
            ];
          };
        };
        # Aspect setting up user share
        provides.share-user-setup = {
          host,
          user,
        }: {
          name = "gaming/steam/share-user-setup(${user.userName}@${host.name})";
          nixos = {lib, ...}: let
            steamCommon = ".local/share/Steam/steamapps/common";
          in {
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

  # Modules
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
    nixos = {
      steam-settings = {lib, ...}: {
        key = "steam-settings#nixos";
        config = {
          # Include hardware support for steam devices
          hardware.steam-hardware.enable = true;
          # Enable steam
          programs.steam = {
            enable = true;
            extest.enable = true;
            dedicatedServer.openFirewall = true;
            # Enable network transfer of steamgames
            localNetworkGameTransfers = {
              openFirewall = true;
            };
            # By default, don't enable remotePlay
            remotePlay = {
              openFirewall = lib.mkDefault false;
            };
          };
        };
      };
      steam-gamescope = {...}: {
        key = "steam-gamescope#nixos";
        config = {
          # Enable steam
          programs = {
            steam = {
              # Enable a desktop session for steam
              gamescopeSession = {
                enable = true;
              };
            };
            # Enable gamescope: steam session
            gamescope = {
              enable = true;
              # TODO: gamescope leaks CAP_SYS_NICE and might not work with bubblewrap
              # capSysNice = true;
            };
          };
        };
      };
    };

    # In home-manager, we set lutris steam to nixos's steam
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
              pkgs.stdenv.hostPlatform.isLinux
              && args.osConfig.programs.steam.enable
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

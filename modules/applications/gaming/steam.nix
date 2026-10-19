# Steam configuration
{
  inputs,
  den,
  lib,
  flib,
  ...
}: {
  # Flake inputs for declarative steam config management
  flake-file.inputs = {
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    # TODO: There is a bug with non-deterministic hash of bun
    # Locking this for now; but when this is fixed this should be undone
    millennium = {
      url = "github:SteamClientHomebrew/Millennium/fb75bf7629562474a7a4cc06a03bb827de28a601?dir=packages/nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

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
                          millennium = lib.mkOption {
                            description = "Enable Millennium launcher for modding steam client";
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
          nixos = {
            lib,
            pkgs,
            ...
          }: {
            config = {
              programs.steam = lib.mkMerge [
                {
                  remotePlay.openFirewall = host.gaming.steam.remotePlay;
                }
                (
                  lib.mkIf
                  (host.gaming.steam.millennium
                    && (pkgs.stdenv.hostPlatform.system == "x86_64-linux"))
                  {
                    package = inputs.millennium.packages."${pkgs.stdenv.hostPlatform.system}".millennium-steam;
                  }
                )
              ];
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
            config = {
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
      steam-settings = {
        lib,
        pkgs,
        ...
      }: {
        key = "steam-settings#nixos";
        config = {
          # Include hardware support for steam devices
          hardware.steam-hardware.enable = true;
          # Enable steam
          programs.steam = {
            enable = true;
            package = lib.mkDefault pkgs.steam;
            extest.enable = true; # For steam on wayland
            dedicatedServer.openFirewall = true;
            protontricks = {
              enable = true;
              package = pkgs.protontricks;
            };
            # Enable network transfer of steamgames
            localNetworkGameTransfers = {
              openFirewall = true;
            };
            # By default, don't enable remotePlay
            remotePlay = {
              openFirewall = lib.mkDefault false;
            };
            # Provide proton ourselves; works really good
            extraCompatPackages = with pkgs; [
              proton-ge-bin # Community proton
              steam-play-none # No linux runtime
            ];
            # Provide gamemode so we can do gamemode with it
            extraPackages = [
              # TODO: This should be provided by config.programs.gamemode.packages
              # Upstream hardcodes this; should submit a patch to the nixos module
              pkgs.gamemode
            ];
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
                steamArgs = [
                  "-tenfoot"
                  "-pipewire-dmabuf"
                ];
                args = [];
                env = {};
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

    # In home-manager, we load the steam-config-nix module
    homeManager.steam-settings = {
      pkgs,
      options,
      lib,
      ...
    }: {
      key = "steam-settings#homeManager";
      # Import steam-config-nix
      imports = [
        (inputs.steam-config-nix.homeModules.default or {})
      ];
      config =
        lib.optionalAttrs
        (lib.hasAttrByPath ["programs" "steam" "config"] options)
        {
          programs.steam.config = {
            enable = true;
            # Turn off steam to update config files on generation activation
            onSteamRunning = "close";
            # Default proton to use nixos' proton
            defaultCompatTool = pkgs.proton-ge-bin;
            # Create desktop entries by default
            desktopEntries.enable = lib.mkDefault true;
          };
        };
    };
  };
}

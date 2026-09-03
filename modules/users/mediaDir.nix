# User media directory externalization implementation
{
  lib,
  flib,
  den,
  ...
}: let
  # Default XDG file locations
  xdgDefaults = {
    linux = {
      "documents" = "Documents";
      "download" = "Downloads";
      "music" = "Music";
      "pictures" = "Pictures";
      "projects" = "Projects";
      "publicShare" = "Shared/Public";
      "videos" = "Videos";
    };
    darwin = {
      "documents" = "Documents";
      "download" = "Downloads";
      "music" = "Music";
      "pictures" = "Pictures";
      "projects" = "Projects";
      "publicShare" = "Public";
      "videos" = "Movies";
    };
  };
in {
  den = {
    # For host schema, configure media directory location
    schema.host = {
      includes = [
        den.aspects.mediaDirs.policies.mediaDirs-host-dispatch
      ];
      imports = [
        # Inline module due to depending on eval and adding includes
        ({config, ...}: {
          options = {
            mediaDir = lib.mkOption {
              type = lib.types.nullOr flib.types.absolutePath;
              description = "Path for externalizing user media directories";
              default =
                if (config.class == "nixos")
                then "/home/media"
                else null;
            };
          };
        })
      ];
    };

    # For user schema, managed media directories
    schema.user = {
      includes = [
        den.aspects.mediaDirs.policies.mediaDirs-user-dispatch
      ];
      # Inline module due to depending on host.system
      imports = [
        ({config, ...}: {
          options = {
            mediaDirs = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf (
                lib.types.submodule (
                  {name, ...}: {
                    options = {
                      location = lib.mkOption {
                        type = flib.types.relativePath;
                        description = "Directory location relative to users' home";
                        default =
                          if (config.host.class == "nixos")
                          then (xdgDefaults.linux.${name} or "Media/${flib.capitalize.name}")
                          else if (config.host.class == "darwin")
                          then (xdgDefaults.darwin.${name} or "Media/${flib.capitalize.name}")
                          else throw "Unsupported host class '${config.host.class}'";
                      };
                      externalize = lib.mkOption {
                        type = lib.types.bool;
                        default = config.host.class == "nixos";
                        description = "Externalize this directory";
                      };
                    };
                  }
                )
              ));
              default =
                if (builtins.elem config.host.class ["nixos" "darwin"])
                then
                  (
                    lib.mapAttrs
                    (_n: _v: {})
                    (xdgDefaults."${config.host.class}" or {})
                  )
                else null;
              description = "Media directories to manage";
            };
          };
        })
      ];
    };

    # Behavior for media dirs
    aspects.mediaDirs = {
      # Policy dispatches
      policies.mediaDirs-user-dispatch = {
        host,
        user,
        ...
      }: (
        []
        ++ (
          lib.optional
          (user.mediaDirs != null)
          (den.lib.policy.include den.aspects.mediaDirs._.mediaUserXdgDirs)
        )
        ++ (
          lib.optional
          ((host.mediaDir != null) && (user.mediaDirs != null))
          (den.lib.policy.include den.aspects.mediaDirs._.mediaUserRoot)
        )
        ++ (
          lib.optional
          ((host.mediaDir != null) && (user.mediaDirs != null) && (user.mediaDirs != {}))
          (den.lib.policy.include den.aspects.mediaDirs._.mediaUserDirs)
        )
      );
      policies.mediaDirs-host-dispatch = {host, ...}: (
        []
        ++ (
          lib.optional
          (host.mediaDir != null)
          (den.lib.policy.include den.aspects.mediaDirs._.mediaRoot)
        )
      );

      # Aspect that creates the media root directory for host once
      provides.mediaRoot = {host}: (
        lib.optionalAttrs (host.mediaDir != null) {
          nixos = {...}: {
            systemd.tmpfiles.settings."30-media-root" = {
              "${host.mediaDir}" = {
                # Create directory with new permissions
                d = {
                  user = "root";
                  group = "users";
                  mode = "3550";
                };
                # Access ACL plus default ACL inherited by new children
                "a+".argument =
                  "g:users:rX,m::rX,"
                  + "d:g:users:rx,d:m::rx";
              };
            };
          };
        }
      );

      # Aspect that sets xdg directories of a user
      provides.mediaUserXdgDirs = {user}: {
        homeManager = {
          pkgs,
          config,
          ...
        }: {
          config = lib.mkMerge [
            (
              # Walk through and set the xdg directory to target
              lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
                xdg.userDirs =
                  user.mediaDirs
                  |> lib.filterAttrs (
                    name: _:
                      lib.elem
                      name
                      (builtins.attrNames xdgDefaults.linux)
                  )
                  |> lib.mapAttrs (
                    _: dir: (
                      lib.mkDefault
                      "${config.home.homeDirectory}/${dir.location}"
                    )
                  );
              }
            )
            (
              lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
                # Walk through and set the xdg directory to hardcoded location
                xdg.userDirs =
                  user.mediaDirs
                  |> lib.filterAttrs (
                    name: _:
                      lib.elem
                      name
                      (builtins.attrNames xdgDefaults.darwin)
                  )
                  |> lib.mapAttrs (
                    name: _: (
                      lib.mkDefault
                      "${config.home.homeDirectory}/${xdgDefaults.darwin.${name}}"
                    )
                  );
              }
            )
          ];
        };
      };

      # Aspect that creates per user the media root folder
      provides.mediaUserRoot = {
        host,
        user,
      }: {
        nixos = {...}: {
          systemd.tmpfiles.settings."31-media-${user.userName}-root" = {
            "${host.mediaDir}/${user.userName}" = {
              # Create directory with new permissions
              d = {
                user = user.userName;
                group = "users";
                mode = "2750";
              };
              # Access ACL plus default ACL inherited by new children
              "a+".argument =
                "g:users:rX,m::rX,"
                + "d:g:users:rx,d:m::rx";
            };
          };
        };
      };

      # Aspect that creates the user media folders, and bind-mounts them
      provides.mediaUserDirs = {
        host,
        user,
      }: {
        # Create and mount requested folders
        nixos = {config, ...}: {
          config = let
            userHome = config.users.users.${user.userName}.home;
            # Grab data record in processable form
            userDirs =
              user.mediaDirs
              |> lib.filterAttrs (_: dir: dir.externalize)
              |> lib.mapAttrs (name: dir: {
                source = "${host.mediaDir}/${user.userName}/${name}";
                target = "${userHome}/${dir.location}";
              });
          in {
            systemd.tmpfiles.settings = {
              # Create source directory folders
              "32-media-${user.userName}-source-folders" =
                userDirs
                |> lib.mapAttrs' (
                  _: dir: (
                    lib.nameValuePair
                    dir.source
                    {
                      d = {
                        user = user.userName;
                        group = "users";
                        mode = "2750";
                      };
                      "a+".argument =
                        "g:users:rX,m::rX,"
                        + "d:g:users:rx,d:m::rx";
                    }
                  )
                );
              # Create the target directory layout
              "33-media-${user.userName}-target-folders" =
                userDirs
                |> builtins.attrValues
                |> map (dir: flib.walkToDir userHome dir.target)
                |> builtins.concatLists
                |> lib.unique
                |> map (
                  parent:
                    lib.nameValuePair
                    parent
                    {
                      d = {
                        user = user.userName;
                        group = "users";
                        mode = "0750";
                      };
                      "a+".argument =
                        "g:users:rX,m::rX,"
                        + "d:g:users:rx,d:m::rx";
                    }
                )
                |> lib.listToAttrs;
            };

            # Create the bind mounts
            fileSystems =
              userDirs
              |> lib.mapAttrs' (
                dirName: dir:
                  lib.nameValuePair
                  "media-${user.userName}-${dirName}"
                  {
                    mountPoint = dir.target;
                    device = dir.source;
                    fsType = "none";
                    options = [
                      "bind"
                      "nofail"
                      "x-systemd.after=systemd-tmpfiles-setup.service"
                    ];
                    depends = [
                      host.mediaDir
                      userHome
                    ];
                  }
              );
          };
        };
      };
    };
  };
}

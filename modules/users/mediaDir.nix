# User media directory externalization implementation
{
  lib,
  flib,
  den,
  ...
}: let
  # Default xdg file locations for parsing later
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
    # Entity schemas for externalized directory feature
    schema = let
      mediaDirsDeclare = system: {
        mediaDirs = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule (
              {name, ...}: {
                options = {
                  location = lib.mkOption {
                    type = flib.types.relativePath;
                    description = "Directory location relative to users' home";
                    default =
                      if lib.hasSuffix "-linux" system
                      then
                        (
                          if builtins.hasAttr name xdgDefaults.linux
                          then xdgDefaults.linux.${name}
                          else "Media/${flib.capitalize name}"
                        )
                      else if lib.hasSuffix "-darwin" system
                      then
                        (
                          if builtins.hasAttr name xdgDefaults.darwin
                          then xdgDefaults.darwin.${name}
                          else "Media/${flib.capitalize name}"
                        )
                      else throw "Unsupported host system ${system}";
                  };
                  externalize = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Externalize this directory";
                  };
                };
              }
            )
          );
          default = {};
          description = "Media directories to manage";
        };
      };
    in {
      # Declare, as part of user and home schema, managed media directories
      user = {
        imports = [
          ({host, ...}: {options = mediaDirsDeclare host.system;})
        ];
        includes = [
          den.aspects.mediaDirs.mediaUserXdgDirs
          den.aspects.mediaDirs.mediaUserRoot
          den.aspects.mediaDirs.mediaUserDirs
        ];
      };
      home = {
        imports = [
          ({home, ...}: {options = mediaDirsDeclare home.system;})
        ];
        includes = [
          den.aspects.mediaDirs.mediaHomeXdgDirs
        ];
      };

      # Declare, a media directory mount for host
      host = {
        imports = [
          ({config, ...}: {
            options = {
              mediaDir = lib.mkOption {
                type = lib.types.nullOr flib.types.absolutePath;
                description = "Path for externalizing user media directories";
                default =
                  if lib.hasSuffix "-linux" config.system
                  then "/home/media"
                  else if lib.hasSuffix "-darwin" config.system
                  then null
                  else null;
              };
            };
          })
        ];

        includes = [
          den.aspects.mediaDirs.mediaRoot
        ];
      };
    };

    aspects.mediaDirs.provides = let
      # Keep here to dispatch to both home and user scopes
      mkHomeXdg = parent: {
        pkgs,
        config,
        ...
      }: {
        config = lib.mkIf (parent.mediaDirs != {}) (lib.mkMerge [
          (
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
              # Walk through and set the xdg directory to target
              xdg.userDirs =
                parent.mediaDirs
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
                parent.mediaDirs
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
        ]);
      };
    in {
      # Aspects setting xdg dirs
      mediaHomeXdgDirs = {home}: {
        homeManager = mkHomeXdg home;
      };
      mediaUserXdgDirs = {user}: {
        homeManager = mkHomeXdg user;
      };

      # Create the media root directory for host once
      mediaRoot = {host}: (
        lib.optionalAttrs (host.mediaDir != null) {
          nixos = {...}: {
            systemd.tmpfiles.settings."30-media-root" = {
              "${host.mediaDir}" = {
                # Create directory with new permissions
                d = {
                  user = "root";
                  group = "users";
                  mode = "3770";
                };
                # Access ACL plus default ACL inherited by new children
                "a+".argument =
                  "g:users:rwX,m::rwX,"
                  + "d:g:users:rwx,d:m::rwx";
              };
            };
          };
        }
      );

      # Create user root
      mediaUserRoot = {
        host,
        user,
      }: (
        lib.optionalAttrs (
          (host.mediaDir != null)
          && (user.mediaDirs != {})
        ) {
          nixos = {...}: {
            systemd.tmpfiles.settings."31-media-${user.userName}-root" = {
              "${host.mediaDir}/${user.userName}" = {
                # Create directory with new permissions
                d = {
                  user = user.userName;
                  group = "users";
                  mode = "2770";
                };
                # Access ACL plus default ACL inherited by new children
                "a+".argument =
                  "g:users:rwX,m::rwX,"
                  + "d:g:users:rwx,d:m::rwx";
              };
            };
          };
        }
      );

      mediaUserDirs = {
        host,
        user,
      }: {
        # Create and mount requested folders
        nixos = {config, ...}: {
          config =
            lib.mkIf (
              (host.mediaDir != null)
              && (user.mediaDirs != {})
            ) (let
              userHome = config.users.users.${user.userName}.home;
              userRoot = "${host.mediaDir}/${user.userName}";
              # Grab data record in processable form
              userDirs =
                user.mediaDirs
                |> lib.filterAttrs (_: dir: dir.externalize)
                |> lib.mapAttrs (name: dir: {
                  source = "${userRoot}/${name}";
                  target = "${userHome}/${dir.location}";
                });
            in {
              systemd.tmpfiles.settings = {
                # Create source directory folders; exposed on parent
                "32-media-${user.userName}-source" =
                  userDirs
                  |> lib.mapAttrs' (
                    _: dir: (
                      lib.nameValuePair
                      dir.source
                      {
                        d = {
                          user = user.userName;
                          group = "users";
                          mode = "2770";
                        };
                        "a+".argument =
                          "g:users:rwX,m::rwX,"
                          + "d:g:users:rwx,d:m::rwx";
                      }
                    )
                  );
                # Create the target directory layout; produce with parents
                "33-media-${user.userName}-parents" =
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
                          "g:users:rwX,m::rwX,"
                          + "d:g:users:rwx,d:m::rwx";
                      }
                  )
                  |> lib.listToAttrs;
              };

              # Create bind mounts
              fileSystems =
                userDirs
                |> lib.mapAttrs' (
                  name: dir:
                    lib.nameValuePair
                    "media-${user.userName}-${name}"
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
            });
        };
      };
    };
  };
}

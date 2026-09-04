# Syncthing; folder information is collected in a quirk
{
  den,
  lib,
  flib,
  ...
}: {
  den = {
    # Quirk for collecting folder information across the fleet
    quirks.syncthing-folders = {
      description = "Registered syncthing folders";
    };

    # Hook into user mediaDirs to enable syncthing metadata emission
    schema.user = {
      imports = [
        ({config, ...}: {
          options.mediaDirs = lib.mkOption {
            type = lib.types.nullOr (lib.types.attrsOf (
              lib.types.submodule ({name, ...}: {
                options.sync = lib.mkOption {
                  default = {};
                  description = "Syncthing settings for this media folder";
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "Sync this media folder with Syncthing";
                      };
                      id = lib.mkOption {
                        type = lib.types.str;
                        default = "${config.userName}-${name}";
                        readOnly = true;
                        description = "Internal folder ID name used by syncthing";
                      };
                      label = lib.mkOption {
                        type = lib.types.str;
                        default = "${flib.capitalize name} (${flib.capitalize config.userName})";
                        readOnly = true;
                        description = "Display label used by syncthing for this folder";
                      };
                      ignore = lib.mkOption {
                        default = {};
                        description = "Ignore pattern usage for this folder";
                        type = lib.types.submodule {
                          options = {
                            enable = lib.mkOption {
                              default = true;
                              description = "Whether to enable creating .stignore file";
                              type = lib.types.bool;
                            };
                            external = lib.mkOption {
                              default = false;
                              description = "Whether to enable external file inclusion";
                              type = lib.types.bool;
                            };
                            text = lib.mkOption {
                              default = [];
                              description = "Lines to include";
                              type = lib.types.oneOf [
                                lib.types.lines
                                (lib.types.listOf lib.types.str)
                              ];
                              apply = value:
                                if builtins.isList value
                                then value
                                else if value == ""
                                then []
                                else
                                  value
                                  |> lib.removeSuffix "\n"
                                  |> lib.splitString "\n";
                            };
                          };
                        };
                      };
                      type = lib.mkOption {
                        type = lib.types.enum [
                          "sendreceive"
                          "sendonly"
                          "receiveonly"
                          "receiveencrypted"
                        ];
                        default = "sendreceive";
                        description = "Syncthing folder type";
                      };
                      versioning = lib.mkOption {
                        type = lib.types.nullOr (lib.types.submodule {
                          freeformType = lib.types.attrsOf lib.types.anything;
                          options.type = lib.mkOption {
                            type = lib.types.enum [
                              "external"
                              "simple"
                              "trashcan"
                              "staggered"
                            ];
                          };
                        });
                        default = {
                          type = "trashcan";
                          params.cleanoutDays = "100";
                        };
                        description = "Versioning settings for this media folder";
                      };
                    };
                  };
                };
              })
            ));
          };
        })
      ];
    };

    aspects.syncthing = {
      provides.user-node = {
        includes = [
          den.aspects.syncthing._.user-node._.folders
        ];

        provides.folders = {
          host,
          user,
          ...
        }: {
          # Collision protection
          name = "syncthing/user-node/folders(${user.userName}@${host.name})";

          # Emit our folders to the folders quirk
          syncthing-folders = {lib, ...}:
            if user.mediaDirs == null
            then []
            else
              user.mediaDirs
              |> lib.filterAttrs (_: dir: dir.sync.enable)
              |> lib.mapAttrsToList (name: dir: {
                # Required metadata, quirk resolution will use this info
                type = "media";
                # Media type folders should just pass through their mediaDir option
                # And their location
                # Ownership etc. will be determined from provenence data
                mediaDir = name;
                # (Don't need this) location = "${user.homeDirectory}/${dir.location}";
              });

          # Establish folders to share. all should be connected with provenance
          homeManager = {
            syncthing-folders,
            lib,
            ...
          }: let
            # Specifically get the media folders in this scope
            mediaFolders =
              syncthing-folders
              # Filter to items that has provenance
              |> lib.filter (f: ((f ? value) && (f ? source)))
              # Filter to items of type media, and of this user
              |> lib.filter (f: (
                (f.value.type == "media")
                && (f.source.user.userName == user.userName)
              ))
              # Morph into an attrset keyed by folder id
              |> builtins.groupBy (q: q.source.user.mediaDirs."${q.value.mediaDir}".sync.id)
              # We have <id> = [ {folderquirk1} {folderquirk2}]
              # Morph each quirk list to valid syncthing setttings
              |> lib.mapAttrs (id: mediaList: (
                let
                  refQuirk = builtins.head mediaList;
                  refFolder = refQuirk.source.user.mediaDirs.${refQuirk.value.mediaDir};
                  localQuirk =
                    lib.findFirst
                    (q: q.source.host.name == host.name)
                    null
                    mediaList;
                  localFolder =
                    if localQuirk != null
                    then localQuirk.source.user.mediaDirs.${localQuirk.value.mediaDir}
                    else null;
                in (
                  {
                    # Redundant, but make it explicit
                    inherit id;
                    # Inherit joint values
                    inherit (refQuirk.value) mediaDir;
                    inherit (refFolder.sync) label;
                    # List of nodes this folder is shared with
                    devices = lib.mkDefault (
                      mediaList
                      |> lib.map (q: q.source.user.syncthing.label)
                      |> lib.unique
                    );
                    # Whether this folder is enabled on this host or not
                    enable =
                      lib.any
                      (q: q.source.host.name == host.name)
                      mediaList;
                    # Realization path
                    path =
                      if localFolder != null
                      then "${user.homeDirectory}/${localFolder.location}"
                      else "~/Syncthing/${flib.capitalize refQuirk.value.mediaDir}";
                  }
                  // (lib.optionalAttrs (localFolder != null) {
                    # Get additional data
                    inherit (localFolder) location;
                    inherit (localFolder.sync) type versioning ignore;
                  })
                )
              ));
          in {
            # Put syncthing folders into our config; ignore is not in hm so filter out
            services.syncthing.settings.folders =
              lib.mapAttrs
              (_: v: builtins.removeAttrs v ["location" "ignore" "mediaDir"])
              mediaFolders;

            # Create default ignore files at target locations
            home.file =
              mediaFolders
              |> lib.filterAttrs (_: v: (v.enable or false))
              |> lib.filterAttrs (_: v: (v.ignore.enable or false))
              |> lib.mapAttrs' (
                _: v: (
                  lib.nameValuePair
                  "${v.mediaDir}-stignore"
                  {
                    target = "${v.location}/.stignore";
                    text = ''
                      // Global stignore for ${v.label}
                      // Managed by home-manager
                      // - Host:    ${host.name}
                      // - User:    ${user.userName}
                      // - Node:    ${user.syncthing.label}
                      // - Folder:  ${v.id}

                      // Do not ignore any extra stignore files
                      !/.stignore.*
                      ${
                        if v.ignore.external
                        then ''
                          // Host-specific ignore file
                          #include .stignore.${host.name}
                        ''
                        else ""
                      }

                      // No thumbnails
                      .thumbnails
                      .thumbnails/**

                      // No VCS
                      (?d).git
                      (?d).gitmodules
                      (?d).jj

                      // OS Junk
                      .Trash-*
                      (?d).DS_Store
                      .localized

                      // Ignore lines set by home-manager for this node
                      // BEGIN (ignore lines for [${v.id}] @ [${user.syncthing.label}])

                      ${lib.concatStringsSep "\n" v.ignore.text}

                      // END   (ignore lines for [${v.id}] @ [${user.syncthing.label}])
                    '';
                  }
                )
              );
          };
        };
      };
    };
  };
}

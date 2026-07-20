# User media directory implementation
{
  den,
  lib,
  flib,
  ...
}: let
  xdgDefaultDirs = {
    "documents" = "Documents";
    "download" = "Downloads";
    "music" = "Music";
    "pictures" = "Pictures";
    "projects" = "Projects";
    "publicShare" = "Shared/Public";
    "videos" = "Videos";
  };
  xdgDefaultDirsDarwin = {
    "documents" = "Documents";
    "download" = "Downloads";
    "music" = "Music";
    "pictures" = "Pictures";
    "projects" = "Projects";
    "publicShare" = "Public";
    "videos" = "Movies";
  };
  xdgTypes = builtins.attrNames xdgDefaultDirs;

  # The registry for mediaDirs
  mediaDirsType = lib.types.submodule ({name, ...}: {
    options = {
      # Overwritable marker for which xdg directory type this is
      xdg = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum xdgTypes);
        default =
          if builtins.hasAttr name xdgDefaultDirs
          then name
          else null;
        description = "Corresponding XDG user dir type";
      };

      # Path inside home directory on where to put this director
      path =
        lib.mkOption {
          type = flib.types.relativePath;
          description = "Folder path of this directory inside home";
        }
        // (
          lib.optionalAttrs (builtins.hasAttr name xdgDefaultDirs) {
            default = xdgDefaultDirs.${name};
          }
        );

      # Flag for whether to externalize this media directory
      external = lib.mkOption {
        type = lib.types.bool;
        description = "Externalize this directory";
        default = true;
      };
    };
  });
in {
  den = {
    # Entity schemas for the media directory feature
    schema = {
      # Declare, as part of user schema, managed media directories
      user = {...}: {
        options = {
          mediaDirs = lib.mkOption {
            type = lib.types.attrsOf mediaDirsType;
            default = {};
          };
        };
      };

      # Declare, a media directory for host
      host = {...}: {
        options = {
          mediaDir = lib.mkOption {
            type = flib.types.absolutePath;
            default = "/home/media";
            description = "Location for base directory of external share";
          };
        };
      };
    };

    # We collect managed directories in a mediaDirs quirk; as an attrset
    quirks.mediaDirs = {
      description = "Resolved user media directory records";
      # Should be keyed as "<user>-<foldername> and have the following information;
      # - name: <foldername>
      # - user: the main user name for this folder
      # - directory: actual path
      # - bindLocation: target to bind this directory to
    };
    policies.expose-mediaDirs = {...} @ ctx: [
      (
        den.lib.policy.pipe.from den.quirks.mediaDirs [
          den.lib.policy.pipe.expose
        ]
      )
    ];

    # Aspect for this collected behavior
    aspects.mediaDirs = {
      # Emit the set settings to the quirk
      emit = {
        host,
        user,
      }: {
        mediaDirs = {};
      };
    };
  };
}

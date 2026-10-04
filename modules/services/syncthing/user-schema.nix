# Syncthing, root for user scoped syncthing daemon settings
{
  lib,
  flib,
  ...
}: {
  den = {
    # Add to user schema
    schema.user = {
      # Options for configuring users' syncthing instance
      imports = [
        ({config, ...}: {
          options = {
            syncthing = lib.mkOption {
              description = "Syncthing options for this user";
              default = {};
              type = lib.types.submodule {
                options = {
                  enable = lib.mkOption {
                    description = "Enable syncthing on this node.";
                    default = false;
                    type = lib.types.bool;
                  };
                  label = lib.mkOption {
                    description = "The nixos internal name for this node";
                    type = lib.types.str;
                    default = "${config.userName}@${config.host.name}";
                    readOnly = true;
                  };
                  name = lib.mkOption {
                    description = "The name for this node sent to syncthing";
                    type = lib.types.str;
                    default = "${flib.capitalize config.userName} on ${flib.capitalize config.host.name}";
                    readOnly = true;
                  };
                  id = lib.mkOption {
                    description = "Public Syncthing node ID";
                    default = null;
                    type = lib.types.nullOr (
                      lib.types.strMatching
                      "[A-Z2-7]{7}(-[A-Z2-7]{7}){7}"
                    );
                  };
                  globalShare = lib.mkOption {
                    description = "Global share folder on this node";
                    default = true;
                    type = lib.types.bool;
                  };
                };
              };
              # Validity check
              apply = cfg:
                if cfg.enable && (cfg.id == null)
                then throw "Valid syncthing device ID required when enabled"
                else cfg;
            };
          };
        })
      ];
    };
  };
}

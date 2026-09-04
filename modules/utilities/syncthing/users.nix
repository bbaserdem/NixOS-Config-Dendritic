# Syncthing, root for user scoped syncthing daemon settings
{
  den,
  lib,
  flib,
  ...
}: {
  den = {
    # Add to user schema
    schema.user = {
      includes = [
        den.aspects.syncthing._.user-node.policies.enable
      ];

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

    # Policy for enabling user node on user scopes
    aspects.syncthing = {
      provides.user-node = {
        policies.enable = {user, ...}: let
          userName = user.userName;
        in
          lib.optionals (user.syncthing.enable) [
            # Enable the user node aspect on this user
            (den.lib.policy.include den.aspects.syncthing._.user-node)
            # Collect devices from other user nodes
            (den.lib.policy.pipe.from den.quirks.syncthing-devices [
              # Collect all other user nodes' information
              (den.lib.policy.pipe.collectAll ({user, ...}: user.syncthing.enable))
              den.lib.policy.pipe.withProvenance
            ])
            # Collect folders from other user nodes
            (den.lib.policy.pipe.from den.quirks.syncthing-folders [
              # Collect all of this user's folders from all matching scopes
              (den.lib.policy.pipe.collectAll ({user, ...}: user.userName == userName))
              den.lib.policy.pipe.withProvenance
            ])
          ];
      };
    };
  };
}

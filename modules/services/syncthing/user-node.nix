# Syncthing; node activation for user-node's
{
  inputs,
  lib,
  den,
  ...
}: {
  den = {
    schema.user = {
      includes = [
        den.aspects.syncthing.policies.user-node-enable
        den.aspects.syncthing.policies.user-node-device-collection
      ];
    };

    # User-node aspect; for setting up a users' individual node
    aspects.syncthing = {
      policies = {
        # Enable policy
        user-node-enable = {user, ...}:
          lib.optional
          user.syncthing.enable
          (den.lib.policy.include den.aspects.syncthing._.user-node);
        # Quirk collection policy
        user-node-device-collection = {user, ...}:
          lib.optional
          user.syncthing.enable
          ( # Collect all relevant devices across the fleet to this scope
            den.lib.policy.pipe.from
            den.quirks.syncthing-devices
            [
              (
                den.lib.policy.pipe.collectAll
                ({user, ...}: user.syncthing.enable)
              )
              den.lib.policy.pipe.withProvenance
            ]
          );
      };

      provides.user-node = {
        name = "syncthing/user-node";
        # Always dispatch base behavior with parametric aspect
        includes = [
          den.aspects.syncthing._.user-node._.setup
        ];

        provides.setup = {
          host,
          user,
        }: let
          # Calculate the lexical offset number out of users with enabled syncthing
          offset =
            host.users
            |> lib.filterAttrs (_: v: v.syncthing.enable)
            |> builtins.attrNames
            |> lib.lists.findFirstIndex
            (u: u == user.name)
            (throw "Could not create user offset");
          # Ports used by this instance; base plus- 1-based offset
          guiPort = 8384 + 1 + offset;
          transferPort = 22000 + 1 + offset;
          discoveryPort =
            if offset == 0
            then 21027 + 1
            else null;
        in {
          # Collision protection
          name = "syncthing/user-node/setup(${user.userName}@${host.name})";

          # Emit our device information; include all base keys except enable flag
          syncthing-devices = {
            # Device label used, along with name and id; and global share
            inherit (user.syncthing) label name id globalShare;
            # Include the ports the machine will be running from
            inherit guiPort transferPort discoveryPort;
          };

          # Emit where our gui address will be bound
          local-web = {
            service = "syncthing";
            subpath = user.userName;
            port = guiPort;
          };

          # Declare our ports to local firewall
          local-ports =
            [
              {
                proto = "all";
                port = transferPort;
              }
            ]
            ++ ( # Register discovery port if enabled
              lib.optional
              (discoveryPort != null)
              {
                proto = "udp";
                port = discoveryPort;
              }
            );

          # Load host-specefic information to home-manager
          homeManager = {
            options,
            config,
            lib,
            pkgs,
            syncthing-devices,
            ...
          }: {
            imports = [
              inputs.self.modules.generic.syncthing-settings
              inputs.self.modules.homeManager.syncthing-settings
            ];
            config = lib.mkMerge [
              (
                # Secrets loading depends on SOPS
                lib.mkIf (options ? sops) {
                  # Add secrets to sops
                  sops.secrets = let
                    keyConf = {
                      mode = "0440";
                    };
                  in {
                    "syncthing/${host.name}/key" = keyConf;
                    "syncthing/${host.name}/cert" = keyConf;
                    "syncthing/${host.name}/restapi" = keyConf;
                  };
                  # Set syncthing secrets
                  services.syncthing = {
                    key = config.sops.secrets."syncthing/${host.name}/key".path;
                    cert = config.sops.secrets."syncthing/${host.name}/cert".path;
                    # API Key setting should be done here when support for this drops
                    # apiKey = config.sops.secrets."syncthing/${host.name}/restapi".path;
                    # Put in syncthing tray secrets API key when this is in
                    tray =
                      lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
                      };
                  };
                }
              )
              {
                services.syncthing = {
                  # Use the new ports for this instance
                  # We will reserve defaults for system based daemons
                  guiAddress = "127.0.0.1:${toString guiPort}";
                  settings = {
                    options = {
                      listenAddresses = [
                        # Do the equivalent of `default`, but with the custom port
                        "tcp://0.0.0.0:${toString transferPort}"
                        "quic://0.0.0.0:${toString transferPort}"
                        "dynamic+https://relays.syncthing.net/endpoint"
                      ];
                      localAnnounceEnabled = discoveryPort != null;
                      localAnnouncePort = discoveryPort;
                    };
                    # Set cookie path location to stop clashes
                    gui.sessionCookiePath = "/${user.userName}/";

                    # Device list, pulled from quirk
                    devices =
                      syncthing-devices
                      |> lib.lists.unique
                      # Self is fine for setting our own node name; don't need to filter
                      |> builtins.map (
                        d:
                          lib.nameValuePair
                          d.value.label
                          {
                            inherit (d.value) name id;
                          }
                      )
                      |> builtins.listToAttrs;
                  };
                };
              }
            ];
          };
        };
      };
    };
  };
}

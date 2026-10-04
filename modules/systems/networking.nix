# Networking setup for global quirks collecting information
{
  den,
  lib,
  ...
}: {
  den = {
    quirks = {
      # Registry quirk for local services
      local-web.description = "Host-local DNS records for local services.";
      local-ports.description = "Host-local port registry.";
      # Derived; it's one attrset that houses info on what should be available
      local-pages.description = "Normalized host-local web routes";
    };

    schema = {
      host = {
        # Create one collected local-pages registry
        includes = [
          den.aspects.system._.networking.policies.normalize-local-pages
        ];
        # Host option to serve the local web pages
        imports = [
          ({config, ...}: {
            options = {
              networking = lib.mkOption {
                description = "Network related metadata";
                default = {};
                type = lib.types.submodule {
                  options = {
                    # Provider for networking backend
                    provider = lib.mkOption {
                      description = "Which provider to use, if any";
                      type = lib.types.nullOr (lib.types.enum [
                        "networkManager"
                        "dhcpd" # TODO: Dhcpd networking setup
                      ]);
                      default =
                        if config.class == "nixos"
                        then "networkManager"
                        else null;
                    };
                    # Local networking
                    local = lib.mkOption {
                      description = "Local networking options";
                      default = {};
                      type = lib.types.submodule {
                        options = {
                          enable = lib.mkOption {
                            description = "Whether to enable local page serving.";
                            type = lib.types.bool;
                            default = false;
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
        # Collect the network info emitted by user scopes for a host
        includes = [
          den.aspects.system._.networking.policies.expose-local-network-records
        ];
      };
    };

    aspects.system = {
      # Auto include networking aspect in all host scopes
      includes = [
        den.aspects.system._.networking
      ];

      provides.networking = {
        name = "system/networking";
        policies = {
          # Push host-user info to the parent host scope
          expose-local-network-records = {...}: [
            (
              den.lib.policy.pipe.from
              den.quirks.local-web
              [den.lib.policy.pipe.expose]
            )
            (
              den.lib.policy.pipe.from
              den.quirks.local-ports
              [den.lib.policy.pipe.expose]
            )
          ];
          # From the records; create a new quirk that will house one standart attrset
          normalize-local-pages = {...}: [
            (
              den.lib.policy.pipe.from
              den.quirks.local-web
              [
                (
                  den.lib.policy.pipe.for
                  (records: [
                    (
                      records
                      |> builtins.groupBy (record: record.service)
                      |> lib.mapAttrs (
                        _: serviceRecords: (
                          serviceRecords
                          |> builtins.map (
                            r:
                              lib.nameValuePair
                              (
                                if
                                  (
                                    (r ? subpath)
                                    && (builtins.isString (r.subpath or ""))
                                    && ((r.subpath or "") != "")
                                  )
                                then "/${r.subpath}/"
                                else "/"
                              )
                              r
                          )
                          |> builtins.listToAttrs
                        )
                      )
                    )
                  ])
                )
                (den.lib.policy.pipe.as "local-pages")
              ]
            )
          ];
        };
      };
    };
  };
}

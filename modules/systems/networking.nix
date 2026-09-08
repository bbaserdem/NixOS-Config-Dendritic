# Networking information, local or total around the system
{
  den,
  lib,
  ...
}: {
  den = {
    quirks = {
      local-web.description = "Host-local DNS records for local services.";
      local-pages.description = "Normalized host-local web routes";
      local-ports.description = "Host-local port registry.";
    };

    schema = {
      # For a host, collect the network info emitted by it's user scopes
      user = {
        includes = [
          den.aspects.system._.networking.policies.expose-local-network-records
        ];
      };
      host = {
        includes = [
          den.aspects.system._.networking.policies.normalize-local-pages
        ];
        options.localWeb = lib.mkOption {
          description = "Local webpage serving functionality.";
          type = lib.types.submodule {
            options = {
              enable = lib.mkOption {
                description = "Whether to enable local page serving.";
                type = lib.types.bool;
                default = false;
              };
            };
          };
          default = {};
        };
      };
    };

    aspects.system = {
      includes = [
        den.aspects.system._.networking
      ];

      provides.networking = {
        includes = [
          den.aspects.system._.networking._.local-web
        ];

        policies = {
          # Push host-user info to the parent host scope
          expose-local-network-records = {user, ...}:
            lib.optionals (user != null) [
              (
                den.lib.policy.pipe.from den.quirks.local-web [
                  den.lib.policy.pipe.expose
                ]
              )
              (
                den.lib.policy.pipe.from den.quirks.local-ports [
                  den.lib.policy.pipe.expose
                ]
              )
            ];

          # From the records; create a new quirk that will house one standart attrset
          normalize-local-pages = {host, ...}:
            lib.optionals (host != null) [
              (
                den.lib.policy.pipe.from den.quirks.local-web [
                  (
                    den.lib.policy.pipe.for (
                      records: [
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
                      ]
                    )
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

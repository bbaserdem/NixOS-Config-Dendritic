# Networking information, local or total around the system
{
  den,
  lib,
  ...
}: {
  den = {
    quirks = {
      local-dns.description = "Host-local DNS records for local services.";
      local-ports.description = "Host-local port registry.";
    };

    schema.user = {
      includes = [
        den.aspects.system.policies.expose-local-network-records
      ];
    };

    aspects.system = {
      policies = {
        # Push host-user info to the parent host scope
        expose-local-network-records = {user, ...}:
          lib.optionals (user != null) [
            (
              den.lib.policy.pipe.from den.quirks.local-dns [
                den.lib.policy.pipe.expose
              ]
            )
            (
              den.lib.policy.pipe.from den.quirks.local-ports [
                den.lib.policy.pipe.expose
              ]
            )
          ];
      };
    };
  };
}

# Network-Manager, for network management
{
  inputs,
  den,
  lib,
  flib,
  ...
}: {
  # Main config options
  config = {
    den = {
      # Policy inclusions
      schema = {
        host.includes = [den.aspects.networking._.nm.policies.nm-host-dispatch];
        user.includes = [den.aspects.networking._.nm.policies.nm-user-dispatch];
      };

      # Aspect
      aspects.networking = {
        provides.nm = {
          name = "networking/nm";

          # Dispatch policy; depends on the networking.provider key set in systems
          policies = {
            nm-host-dispatch = {host, ...}:
              lib.optionals
              (host.networking.provider == "networkManager")
              (
                [
                  (den.lib.policy.include den.aspects.networking._.nm)
                ]
                ++ (
                  lib.optional
                  host.sops.enable
                  (den.lib.policy.include den.aspects.networking._.nm._.endpoints)
                )
              );
            nm-user-dispatch = {host, ...}:
              lib.optional
              (host.networking.provider == "networkManager")
              (den.lib.policy.include den.aspects.networking._.nm._.to-users);
          };

          # Base enables
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.networkManager-setup
            ];
          };

          # The endpoint setup; from the configured module
          provides.endpoints = {
            name = "networking/nm/endpoints";
            nixos = {...}: {
              imports = [
                inputs.self.modules.nixos.networkManager-endpoints
              ];
            };
          };

          # Set all users as networkmanager users
          provides.to-users = {
            host,
            user,
          }: {
            name = "networking/nm(${user.userName}@${host.name})";
            user = flib.den.addUserToGroups ["networkmanager"];
          };
        };
      };
    };

    # Basic networkmanager settings enable
    flake.modules.nixos.networkManager-setup = {...}: {
      key = "networkManager-setup#nixos";
      config = {
        # Enable network manager for networking
        networking.networkmanager.enable = true;
        # Enable timezoned
        services.automatic-timezoned.enable = true;
      };
    };
  };
}

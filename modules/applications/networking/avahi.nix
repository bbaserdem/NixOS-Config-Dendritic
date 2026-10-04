# Avahi; zeroconf network discovery
{
  inputs,
  den,
  lib,
  ...
}: {
  # Den; this is configured as a host capability
  den = {
    schema.host = {
      includes = [
        den.aspects.networking.policies.avahi-host-dispatch
      ];
      options = {
        networking = lib.mkOption {
          type = lib.types.submodule {
            options = {
              zeroconf = lib.mkOption {
                description = "Zeroconf networking. (NixOS only)";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Enable Avahi on this host";
                      default = false;
                      type = lib.types.bool;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

    aspects.networking = {
      # Dispatch policy
      policies.avahi-host-dispatch = {host, ...}:
        lib.optional
        host.networking.zeroconf.enable
        (den.lib.policy.include den.aspects.networking._.avahi);

      # Aspect
      provides.avahi = {
        name = "networking/avahi";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.avahi
          ];
        };
      };
    };
  };

  # Module
  flake.modules.nixos.avahi = {lib, ...}: {
    key = "avahi#nixos";
    config = {
      services.avahi = {
        enable = true;
        openFirewall = true;
        # Enable DNS resolution by us as well
        nssmdns4 = true;
        # Publishing rules
        publish = {
          # Enable publishing, these are all mkDefault so can be overridden at host level
          enable = lib.mkDefault true;
          # Publish us as <hostname>.local
          addresses = lib.mkDefault true;
          # Don't need to advertise as a desktop computer; off by default
          workstation = lib.mkDefault false;
          # Allow users to publish avahi service files
          userServices = lib.mkDefault true;
          # Don't leak hardware info to the network
          hinfo = lib.mkDefault false;
          # Tell services that .local is a domain worth browsing for services
          domain = true;
        };
      };
    };
  };
}

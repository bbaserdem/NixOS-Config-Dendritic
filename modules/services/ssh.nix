# SSH server to access a host remotely (different than ssh client)
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    schema.host = {
      includes = [
        den.aspects.ssh.policies.ssh-host-dispatch
      ];
      options = {
        networking = lib.mkOption {
          type = lib.types.submodule {
            options = {
              ssh = lib.mkOption {
                description = "SSH settings for this host.";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = ''
                        Whether to enable SSH access to this machine
                        (SSH access is seperate from SSH userspace tooling)
                      '';
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

    aspects.ssh = {
      name = "ssh";
      policies.ssh-host-dispatch = {host, ...}:
        lib.optional
        host.networking.ssh.enable
        (den.lib.policy.include den.aspects.ssh);
      # TODO: Do our local port implementation
      nixos = {...}: {
        imports = [
          inputs.self.modules.nixos.ssh
        ];
      };
      # TODO: Also do darwin stuff too
    };
  };

  flake.modules = {
    # Nixos SSH config
    nixos.ssh = {...}: {
      key = "ssh#nixos";
      config = {
        services = {
          # SSH server
          openssh = {
            enable = true;
            # Listen on all interfaces (DHCP IP will be assigned dynamically)
            listenAddresses = [
              {
                addr = "0.0.0.0";
                port = 22;
              }
            ];
            settings = {
              PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
              PermitRootLogin = "no";
              # Security settings
              MaxAuthTries = 3;
              ClientAliveInterval = 300;
              ClientAliveCountMax = 2;
              X11Forwarding = true; # We need graphical forwarding
              # For fail2ban defaults to work well
              LogLevel = "VERBOSE";
            };
            openFirewall = true;
          };

          # Fail2ban for additional SSH protection
          fail2ban = {
            enable = true;
            maxretry = 3;
            # Don't ban private local networks
            ignoreIP = [
              "127.0.0.0/8"
              "10.0.0.0/8"
              "172.16.0.0/12"
              "192.168.0.0/16"
            ];
            # TODO: Set up the jail
            # jails = { };
          };
        };
      };
    };
  };
}

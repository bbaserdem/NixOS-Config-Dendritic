# Global GPG
{
  inputs,
  den,
  lib,
  ...
}: {
  # Den
  den = {
    # Schema; register policies
    schema = {
      host = {
        includes = [
          den.aspects.tools.policies.gpg-host-dispatch
        ];
        options = {
          tools = lib.mkOption {
            type = lib.types.submodule {
              options = {
                gpg = lib.mkOption {
                  description = "Enable gpg tooling";
                  default = true;
                  type = lib.types.bool;
                };
              };
            };
          };
        };
      };
      user = {
        includes = [
          den.aspects.tools.policies.gpg-user-dispatch
        ];
      };
    };

    aspects.tools = {
      # Policy
      policies = {
        gpg-host-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.gpg)
          [
            (den.lib.policy.include den.aspects.tools._.gpg)
          ];
        gpg-user-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.gpg)
          [
            (den.lib.policy.include den.aspects.tools._.gpg._.to-users)
          ];
      };
      # Aspect
      provides.gpg = {
        name = "tools/gpg";
        os = {...}: {
          imports = [
            inputs.self.modules.generic.gpg-settings
          ];
        };
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.gpg-settings
          ];
        };
        darwin = {...}: {
          imports = [
            inputs.self.modules.darwin.gpg-settings
          ];
        };
        provides.to-users = {
          host,
          user,
        }: {
          # Clash check
          name = "tools/gpg(${user.userName}@${host.name})";
          # Module dispatch
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.gpg-settings
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Nixos
    nixos.gpg-settings = {pkgs, ...}: {
      key = "gpg-settings#nixos";
      config = {
        # Install all pinentry packages
        environment.systemPackages = with pkgs; [
          pinentry-all
        ];
        # Further gnupg settings
        programs.gnupg = {
          agent = {
            enableBrowserSocket = true;
            enableExtraSocket = true;
          };
        };
      };
    };
    # Darwin; install pinentry
    darwin.gpg-settings = {pkgs, ...}: {
      key = "gpg-settings#darwin";
      config = {
        environment.systemPackages = with pkgs; [
          pinentry_mac
        ];
      };
    };
    # Both OSes; enable gnupg agent system wide
    generic.gpg-settings = {...}: {
      key = "gpg-settings#generic";
      config = {
        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };
      };
    };
    # Home manager users; enable gpg
    homeManager.gpg-settings = {config, ...}: {
      key = "gpg-settings#homeManager";
      config = {
        # Enable GPG
        programs.gpg = {
          enable = true;
          homedir = "${config.xdg.dataHome}/gnupg";
          mutableKeys = true;
          mutableTrust = true;
          # Strong algorithm preferences
          settings = {
            personal-cipher-preferences = "AES256";
            personal-digest-preferences = "SHA512";
            cert-digest-algo = "SHA512";
            s2k-cipher-algo = "AES256";
            s2k-digest-algo = "SHA512";
            s2k-count = "65011712";
          };
        };

        # Enable gpg agent
        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
          # Cache key for 10 minutes, max 2 hours
          defaultCacheTtl = 600;
          maxCacheTtl = 7200;
          defaultCacheTtlSsh = 600;
          maxCacheTtlSsh = 7200;
          # Enable loopback pinentry
          extraConfig = "allow-loopback-pinentry";
          # Shell integrations
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
        };
      };
    };
  };
}

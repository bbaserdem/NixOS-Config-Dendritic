# Archiving utilities
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Schema; register policies
    schema = {
      host = {
        includes = [
          den.aspects.tools.policies.archives-host-dispatch
        ];
        options = {
          tools = lib.mkOption {
            type = lib.types.submodule {
              options = {
                archives = lib.mkOption {
                  description = "Enable installing archiving utilities";
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
          den.aspects.tools.policies.archives-user-dispatch
        ];
      };
    };

    aspects.tools = {
      # Policy
      policies = {
        archives-host-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.archives)
          [
            (den.lib.policy.include den.aspects.tools._.archives)
          ];
        archives-user-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.archives)
          [
            (den.lib.policy.include den.aspects.tools._.archives._.to-users)
          ];
      };
      # Aspect
      provides.archives = {
        name = "tools/archives";
        os = {...}: {
          imports = [
            inputs.self.modules.generic.tools-archives
          ];
        };
        homeManager = {...}: {
          imports = [
            inputs.self.modules.homeManager.tools-archives
          ];
        };
        provides.to-users = {
          host,
          user,
        }: {
          name = "tools/archives(${user.userName}@${host.name})";
          # Home manager module loading
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.tools-archives
            ];
          };
        };
      };
    };
  };

  flake.modules = let
    # Common function that returns the package set; to set to both modules
    archivePkgs = pkgs: (
      with pkgs;
        [
          # Unconditional
          patool
          atool
          zip
          bzip2
          bzip3
          p7zip
          ncompress
          gzip
          rzip
          gnutar
          xz
          zstd
        ]
        ++ ( # not available in arm linux
          lib.optional
          (pkgs.stdenv.hostPlatform.system != "aarch64-linux")
          rar
        )
    );
  in {
    # Include to homeManager
    generic.tools-archives = {pkgs, ...}: {
      key = "tools-archives#generic";
      config = {
        environment.systemPackages = archivePkgs pkgs;
      };
    };

    # Install to user
    homeManager.tools-archives = {pkgs, ...}: {
      key = "tools-archives#homeManager";
      config = {
        home.packages = archivePkgs pkgs;
      };
    };
  };
}

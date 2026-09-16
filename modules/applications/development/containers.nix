# Configuring container backends
{inputs, ...}: {
  den = {
    aspects.applications = {
      provides.containers = {
        provides.to-users = {
          host,
          user,
        }: {
          name = "applications/containers(${user.userName}@${host.name})";
          # Enable podman in nixos
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.containers-podman
            ];
          };
          # Enable orbstack in darwin hm
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.containers-orbstack
            ];
          };
        };
      };
    };
  };

  # Use podman in linux
  flake.modules.nixos.containers-podman = {pkgs, ...}: {
    key = "containers-podman#nixos";
    config = {
      # Setup podman for nixos
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings = {
          dns_enabled = true;
          driver = "bridge";
        };
      };
      # Add podman-compose
      environment.systemPackages = with pkgs; [
        podman-compose
      ];
    };
  };

  # Use orbstack in darwin; in userspace
  flake.modules.homeManager.containers-orbstack = {
    pkgs,
    lib,
    ...
  }: {
    key = "containers-orbstack#homeManager";
    config = lib.mkMerge [
      (
        # Darwin guard
        lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          home.packages = with pkgs; [
            orbstack
          ];
        }
      )
    ];
  };
}

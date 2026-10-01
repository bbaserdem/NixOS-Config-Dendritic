# Enabling remmina
{inputs, ...}: {
  # Aspect
  den = {
    aspects.networking = {
      provides.remmina = {
        name = "networking/remmina";
        provides.to-users = {
          user,
          host,
        }: {
          name = "networking/remmina(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.remmina-settings
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.remmina-settings = {
    lib,
    pkgs,
    ...
  }: {
    key = "remmina-settings#homeManager";
    config = lib.mkMerge [
      {
        services.remmina.enable = true;
      }
      ( # Systemd and XDG only in linux
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          services.remmina = {
            systemdService.enable = true;
            addRdpMimeTypeAssoc = true;
          };
        }
      )
    ];
  };
}

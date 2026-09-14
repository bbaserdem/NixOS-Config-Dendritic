# Enabling remmina
{...}: {
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
      (
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

# Syncthing setting modules; outside den
{...}: {
  flake.modules = {
    # Generic module for enabling syncthing on nixos or on home-manager
    generic.syncthing-settings = {lib, ...}: {
      services.syncthing = {
        enable = true;
        settings.options = {
          urAccepted = 3;
          relaysEnabled = true;
          # Default to enabling this; settings overridden on user level
          localAnnounceEnabled = lib.mkDefault true;
        };
      };
    };
    # Home-manager level syncthing settings
    homeManager.syncthing-settings = {
      lib,
      pkgs,
      ...
    }: {
      config = lib.mkMerge [
        (
          # Syncthing tray for linux only
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            services.syncthing.tray = {
              enable = true;
              package = pkgs.syncthingtray;
            };
          }
        )
      ];
    };
    # Nixos module for enabling syncthing side services on nixos
    nixos.syncthing-services = {...}: {
      services.syncthing = {
        relay = {
          enable = true;
        };
      };
    };
  };
}

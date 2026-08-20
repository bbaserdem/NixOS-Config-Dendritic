# Den implementation for generating devices list
{den, ...}: {
  den = {
    aspects.syncthing = {
      includes = [
        den.aspects.syncthing.devicesHost
        den.aspects.syncthing.devicesHome
      ];

      provides = {
      };
    };
  };

  flake.modules = {
    # Syncthing module to generate proper device list
    generic.syncthing-devices = {...}: {
    };

    # Home-manager; enable syncthing for the primaryUser
    homeManager.syncthing-devices = {...}: {
      services.syncthing.enable = true;
    };
  };
}

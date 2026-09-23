# Configuring OS defaults for macos systems
{
  inputs,
  den,
  ...
}: {
  den.aspects = {
    system = {host}: {
      darwin = {lib, ...}: {
        includes = [
          den.aspects.system._.macos-dbus
        ];
        imports = with inputs.self.modules.darwin; [
          # Base modules to configure the system
          macos-filesystem
          macos-homebrew
          macos-settings
        ];
        config = {
          # Default state version for this nix-darwin
          system.stateVersion = lib.mkDefault 7;
          # Full computer name
          networking.computerName = host.description;
        };
      };
    };
  };

  # TODO: Delete after den migration
  flake.modules.darwin.macos = {
    lib,
    options,
    ...
  }: {
    imports = with inputs.self.modules.darwin; [
      nix
      homeManager
      shell
      # Submodules
      macos-homebrew
      macos-filesystem
      macos-dbus
      inputs.self.modules.generic.filesystem
      macos-settings
      macos-local
      macos-networking
    ];
    config = lib.mkIf (options ? home-manager) {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.macos-dbus
      ];
    };
  };

  flake.modules.darwin.macos-local = {lib, ...}: {
    # Mirrors the "to-be-deprecated" system.primaryUser option
    options = {
      local.mainUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          The user that can be configured by modules in this flake.
        '';
      };
    };
  };
}

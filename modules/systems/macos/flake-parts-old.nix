# TODO: Delete after den migration
{inputs, ...}: {
  # macos.nix
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
      inputs.self.modules.generic.os-filesystem
      macos-dbus
      macos-defaults
      macos-behavior
      macos-local
      macos-networking
      caddy
      caddy-local
    ];
    config = lib.mkIf (options ? home-manager) {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.macos-dbus
        inputs.self.modules.homeManager.hm-networking
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

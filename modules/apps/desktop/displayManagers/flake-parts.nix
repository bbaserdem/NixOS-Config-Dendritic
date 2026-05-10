# Display manager setup for nixos systems
{...}: {
  flake.modules.nixos.default = {
    lib,
    config,
    ...
  }: {
    # Local option for hosts to set the display manager
    # Each display manager module sets this option
    # The value would error out if the modules are loaded concurrently
    options = {
      local.displayManager = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [
          "gdm"
          "sddm"
          "regreet"
        ]);
        default = null;
        description = ''
          Display manager to be used by the nixos system
        '';
      };
    };

    # Application of the selected options
    config = lib.mkMerge [
      (
        lib.mkIf (config.local.displayManager == "gdm") {
          services.displayManager.gdm.enable = true;
        }
      )
      (
        lib.mkIf (config.local.displayManager == "sddm") {
          services.displayManager.sddm.enable = true;
        }
      )
      (
        lib.mkIf (config.local.displayManager == "regreet") {
          programs.regreet.enable = true;
        }
      )
    ];
  };
}

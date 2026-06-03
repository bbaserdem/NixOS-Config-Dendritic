# Launcher used for hyprland
{...}: {
  flake.modules.homeManager = {
    # Enable stylix integration
    stylix = {...}: {
      stylix.targets.fuzzel = {
        enable = true;
        colors.enable = true;
        fonts.enable = true;
        icons.enable = true;
        opacity.enable = true;
        polarity.enable = true;
      };
    };
    # Enable in userspace
    hyprland = {
      lib,
      pkgs,
      ...
    }: {
      config = lib.mkMerge [
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            programs.fuzzel = {
              enable = true;
              settings = {
                main = {
                  dpi-aware = "auto";
                  minimal-lines = false;
                  launch-prefix = "${pkgs.runapp}/bin/runapp ";
                };
              };
            };
          }
        )
      ];
    };
  };
}

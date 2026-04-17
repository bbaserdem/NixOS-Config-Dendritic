# Foliate, ebook reader
{...}: {
  flake.modules.homeManager = {
    # Enable stylix theming
    stylix = {...}: {
      stylix.targets.foliate.enable = true;
    };

    # Enable foliate
    foliate = {
      pkgs,
      lib,
      ...
    }: {
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        programs.foliate = {
          enable = true;
        };
      };
    };
  };
}

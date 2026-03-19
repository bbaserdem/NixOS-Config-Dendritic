# Foliate, ebook reader
{...}: {
  flake.modules.home-manager = {
    # Enable stylix theming
    stylix = {...}: {
      stylix.targets.foliate.enable = true;
    };

    # Enable foliate
    foliate = {...}: {
      programs.foliate = {
        enable = true;
      };
    };
  };
}

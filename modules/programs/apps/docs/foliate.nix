# Foliate, ebook reader
{...}: {
  flake.modules.homeManager = {
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

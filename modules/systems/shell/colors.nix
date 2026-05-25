# Shell apps to install
{...}: {
  flake.modules.homeManager = {
    stylix = {...}: {
      # TODO; Apapt to new stylix outputs in 26.05
      # stylix.targets.vivid = {
      #   enable = true;
      #   colors.enable = true;
      # };
    };
    shell = {...}: {
      programs.vivid = {
        enable = true;
      };
    };
  };
}

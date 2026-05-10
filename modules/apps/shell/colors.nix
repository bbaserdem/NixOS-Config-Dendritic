# Shell apps to install
{...}: {
  flake.modules.homeManager = {
    shell = {...}: {
      programs.vivid = {
        enable = true;
      };
    };
    stylix = {...}: {
      stylix.targets.vivid = {
        enable = true;
        colors.enable = true;
      };
    };
  };
}

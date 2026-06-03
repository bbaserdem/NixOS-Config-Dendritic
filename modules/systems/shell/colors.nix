# Shell apps to install
{...}: {
  flake.modules.homeManager = {
    stylix = {...}: {
      stylix.targets.vivid = {
        enable = true;
        colors.enable = true;
      };
    };
    shell = {...}: {
      programs.vivid = {
        enable = true;
      };
    };
  };
}

# Configuring vcs systems personally
{...}: {
  flake.modules.homeManager.batuhan = {...}: {
    programs = {
      # Git customization
      git = {
        settings = {
          alias = {
            pu = "push";
            co = "checkout";
            cm = "commit";
          };
        };
      };
    };
  };
}

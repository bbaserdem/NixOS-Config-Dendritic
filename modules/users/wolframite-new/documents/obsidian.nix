# Obsidian personal config
# TODO: Do this setup
{...}: {
  flake.modules.homeManager.wolframite-obsidian = {...}: {
    key = "wolframite-obsidian";
    config = {
      programs.obsidian = {
        vaults = {
          # Vaults to manage on system level
        };
      };
    };
  };
}

# Obsidian personal config
{...}: {
  flake.modules.homeManager.wolframite = {...}: {
    programs.obsidian = {
      vaults = {
        # Vaults to manage on system level
      };
    };
  };
}

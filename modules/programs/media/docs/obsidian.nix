# Obsidian config
{...}: {
  flake.modules.homeManager = {
    # Enable stylix theming
    stylix = {config, ...}: {
      stylix.targets.obsidian = {
        enable = true;
        colors.enable = true;
        fonts.enable = true;
        polarity.enable = true;
        # If home-manager is managing the vault, apply themes to that vault
        vaultNames = builtins.attrNames config.programs.obsidian.vaults;
      };
    };

    # Enable obsidian
    obsidian = {...}: {
      programs.obsidian = {
        enable = true;
      };
    };
  };
}

# Zathura
{...}: {
  flake.modules.home-manager = {
    # Enable stylix theming
    stylix = {config, ...}: {
      stylix.targets.obsidian = {
        enable = true;
        colors.enable = true;
        fonts.enable = true;
        polarity.enable = true;
        # If home-manager is managing the vault, apply themes to that vaulty
        vaultNames = builtins.attrNames config.programs.obsidian.vaults;
      };
    };

    # Enable obsidian
    obsidian = {...}: {
      programs.obsidian = {
        enable = true;
        vaults = {
          # Vaults to manage on system level
        };
      };
    };
  };
}

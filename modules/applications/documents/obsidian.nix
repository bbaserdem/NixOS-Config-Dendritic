# Obsidian; note taking software
{inputs, ...}: {
  # Application setup with den
  den = {
    aspects.applications = {
      provides.obsidian = {
        provides.to-users = {
          user,
          host,
        }: {
          name = "applications/obsidian(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.obsidian-settings
            ];
          };
          stylix = {
            targets.obsidian = {
              enable = true;
              colors.enable = true;
              fonts.enable = true;
              polarity.enable = true;
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.obsidian-settings = {...}: {
    key = "obsidian-settings#homeManager";
    config = {
      programs.obsidian = {
        enable = true;
      };
    };
  };
}

# Obsidian; note taking software
# TODO: Set up obsidian
{inputs, ...}: {
  # Aspect
  den = {
    aspects.documents = {
      provides.obsidian = {
        name = "documents/obsidian";
        provides.to-users = {
          user,
          host,
        }: {
          name = "documents/obsidian(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.obsidian-settings
            ];
          };
          # Stylix theming as well
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

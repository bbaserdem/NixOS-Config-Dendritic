# Btop; system monitor settings
{inputs, ...}: {
  den = {
    aspects.applications = {
      provides.btop = {
        provides.to-users = {
          host,
          user,
        }: {
          # Clash check
          name = "applications/btop(${user.userName}@${host.name})";
          # Module dispatch
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.btop-settings
            ];
          };
          # Styling
          stylix = {
            targets.btop = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.btop-settings = {...}: {
    key = "btop-settings#homeManager";
    config = {
      programs.btop = {
        enable = true;
        settings = {
          proc_sorting = "cpu lazy";
        };
      };
    };
  };
}

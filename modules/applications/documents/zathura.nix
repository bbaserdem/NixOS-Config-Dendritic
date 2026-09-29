# Zathura; minimal pdf viewer
{inputs, ...}: {
  # Aspect
  den = {
    aspects.documents = {
      provides.zathura = {
        name = "documents/zathura";
        provides.to-users = {
          user,
          host,
        }: {
          name = "documents/zathura(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.zathura-settings
            ];
          };
          stylix = {
            targets.zathura = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Module
  # TODO: Confirm zathura synctex works on darwin
  flake.modules.homeManager.zathura-settings = {...}: {
    key = "zathura-settings#homeManager";
    config = {
      programs.zathura = {
        enable = true;
        mappings = {
          "<C-i>" = "recolor";
        };
        options = {
          recolor-keephue = true;
          selection-keyboard = "clipboard";
          first-page-column = "1:1";
          incremental-search = false;
          statusbar-home-tilde = true;
          scroll-page-aware = true;
          scroll-step = 50;
        };
      };
    };
  };
}

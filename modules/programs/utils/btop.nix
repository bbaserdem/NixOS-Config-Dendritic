# Btop; system monitor
{inputs, ...}: {
  flake.modules = {
    # Include to system
    generic.btop = {...}: {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.btop
      ];
    };
    nixos.btop = inputs.self.modules.generic.btop;
    darwin.btop = inputs.self.modules.generic.btop;

    homeManager = {
      # Enable stylix theming
      stylix = {...}: {
        stylix.targets.btop.enable = true;
      };

      # Enable in home-manager
      btop = {...}: {
        programs.btop = {
          enable = true;
          settings = {
            proc_sorting = "cpu lazy";
          };
        };
      };
    };
  };
}

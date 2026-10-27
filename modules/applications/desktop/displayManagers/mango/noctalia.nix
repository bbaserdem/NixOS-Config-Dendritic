# Noctalia shell for mango
{inputs, ...}: {
  # Modules
  flake.modules = {
    nixos.mango-noctalia = {...}: {
      key = "mango-noctalia#nixos";
      imports = with inputs.self.modules.nixos; [
        noctalia
      ];
      config = {
        # Set noctalia to launch in mango with systemd user service
        programs.noctalia.systemd = {
          enable = true;
          target = "wayland-session@mango.target";
        };
      };
    };
    homeManager.mango-noctalia = {...}: {
      key = "mango-noctalia#homeManager";
      imports = with inputs.self.modules.homeManager; [
        noctalia
      ];
      config = {
      };
    };
  };
}

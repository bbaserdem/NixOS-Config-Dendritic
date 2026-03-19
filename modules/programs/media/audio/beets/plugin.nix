# Configuring Beets
{...}: {
  flake.modules.home-manager.beets = {...}: {
    # Link our plugin in
    xdg.dataFile."beets/beetsplug/sbp.py".source = ./sbp.py;

    # Load our plugin with beets
    programs.beets = {
      settings = {
        plugins = [
          "sbp"
        ];
      };
    };
  };
}

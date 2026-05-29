# Configuring Beets
#
{inputs, ...}: {
  flake.modules.homeManager.wolframite = {...}: {
    # Link our plugin in
    xdg.dataFile."beets/beetsplug/sbp.py".source = inputs.self + /assets/wolframite/sbp.py;

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

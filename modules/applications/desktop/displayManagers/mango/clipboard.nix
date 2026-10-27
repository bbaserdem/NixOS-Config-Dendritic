# Clipboard management; conditional on mango uwsm session
{...}: {
  flake.modules.homeManager.mango-clipboard = {...}: {
    key = "mango-clipboard#homeManager";
    config = {
      services = {
        # Clipboard history management
        cliphist = {
          enable = true;
          systemdTargets = ["wayland-session@mango.target"];
        };
        # Retain clipboard contents when applications quit
        wl-clip-persist = {
          enable = true;
          systemdTargets = ["wayland-session@mango.target"];
          # Filter sensitive just in case
          extraOptions = [
            "--all-mime-type-regex"
            "^(?!x-kde-passwordManagerHint).+"
          ];
        };
      };
    };
  };
}

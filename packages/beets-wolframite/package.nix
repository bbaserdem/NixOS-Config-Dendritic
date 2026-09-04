{pkgs, ...}: let
  py = pkgs.unstable.python3.pkgs;
  beetsAlternatives = py.beets-alternatives.overridePythonAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace beetsplug/alternatives.py \
          --replace-fail \
        '            fmt = config["formats"].as_str()' \
        '            fmt = config["formats"].get()' \
          --replace-fail \
        '            assert isinstance(fmt, str)' \
        '            if not isinstance(fmt, str): fmt = " ".join(fmt)' \
          --replace-fail \
        '            dir = config["directory"].as_path()' \
        '            dir = Path(config["directory"].get(str)).expanduser()' \
          --replace-fail \
        '                self.alternative(name, lib).update(create=options.create)' \
        '                self.alternative(name, lib).update(create=options.create); beets.plugins.send("alternatives.collection_updated", lib=lib, collection=name)' \
          --replace-fail \
        '            alt.update(create=options.create)' \
        '            alt.update(create=options.create); beets.plugins.send("alternatives.collection_updated", lib=lib, collection=options.name)'
      '';
  });
in
  py.beets.override {
    pluginOverrides = {
      alternatives = {
        enable = true;
        propagatedBuildInputs = [beetsAlternatives];
      };
      filetote = {
        enable = true;
        propagatedBuildInputs = [py.beets-filetote];
      };
      wolframite = {
        enable = true;
        propagatedBuildInputs = [py.local.beets-wolframite];
      };
    };
  }

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
    extraPatches = [
      (pkgs.writeText "beets-convert-safe-failure-cleanup.patch" ''
        --- a/beetsplug/convert.py
        +++ b/beetsplug/convert.py
        @@ -339,6 +339,10 @@ class ConvertPlugin(BeetsPlugin):
                     self._log.info("{}", " ".join(args))
                     return

        +        cleanup_on_failure = (
        +            dest_bytes in _temp_files or not os.path.lexists(dest)
        +        )
        +
                 try:
                     util.command_output(encode_cmd)
                 except subprocess.CalledProcessError as exc:
        @@ -352,8 +356,9 @@ class ConvertPlugin(BeetsPlugin):
                         args,
                         exc,
                     )
        -            util.remove(dest)
        -            util.prune_dirs(os.path.dirname(dest))
        +            if cleanup_on_failure:
        +                util.remove(dest)
        +                util.prune_dirs(os.path.dirname(dest))
                     raise
                 except OSError as exc:
                     raise UserError(
      '')
    ];

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

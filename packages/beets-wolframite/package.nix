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
        '            dir = Path(config["directory"].get(str)).expanduser()'
      '';
  });
in
  (py.beets.override {
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
  }).overridePythonAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace beets/importer/stages.py \
          --replace-fail \
        '    task.set_choice(Action.ASIS)
            _resolve_duplicates(session, task)' \
        '    task.set_choice(Action.ASIS)
            plugins.send("import_task_choice", session=session, task=task)
            _resolve_duplicates(session, task)'
        substituteInPlace beets/importer/stages.py \
          --replace-fail \
        '    _resolve_duplicates(session, task)
            _apply_choice(session, task)' \
        '    _resolve_duplicates(session, task)
            if task.duplicate_action is DuplicateAction.MERGE:
                duplicate_items = task.duplicate_items(session.lib)
                _freshen_items(duplicate_items)
                duplicate_paths = [item.path for item in duplicate_items]
                task.items.extend(duplicate_items)
                task.paths.extend(duplicate_paths)
                session.mark_merged(duplicate_paths)
                plugins.send("import_task_choice", session=session, task=task)
            _apply_choice(session, task)'
        substituteInPlace beets/importer/tasks.py \
          --replace-fail \
        '        info["albumartist"] = info["artist"]' \
        '        info["albumartist"] = self.items[0].albumartist or info["artist"]' \
          --replace-fail \
        '            if write and (self.apply or self.choice_flag == Action.RETAG):' \
        '            if write and (self.apply or self.choice_flag == Action.RETAG) and not getattr(self, "_wolframite_defer_media_write", False):' \
          --replace-fail \
        '                item.try_write()' \
        '                if not item.try_write(): raise RuntimeError(f"failed to write tags for {item.filepath}")'
        substituteInPlace beets/importer/stages.py \
          --replace-fail \
        '        item.id = None' \
        '        item.read(); item.id = None'
        substituteInPlace beets/ui/commands/update.py \
          --replace-fail \
        'from beets import library, logging, ui' \
        'from beets import library, logging, plugins, ui' \
          --replace-fail \
        '            # Check for and display changes.' \
        '            if not pretend: plugins.send("wolframite.item_fields_read", lib=lib, item=item)

            # Check for and display changes.'
        substituteInPlace beetsplug/edit.py \
          --replace-fail \
        '            apply_(obj, new_dict)' \
        '            apply_(obj, {key: value for key, value in new_dict.items() if old_dict.get(key) != value})'
      '';
  })

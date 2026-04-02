# Flake parts module for using templates
# We prefix each folder with _ to avoid auto-import from seeing them
{...}: {
  flake.templates = {
    workPython = {
      path = ./_workPython;
      description = "Repo starter for a python project, for work";
    };
    workLean = {
      path = ./_workLean;
      description = "Repo starter for a node+lean project, for work.";
    };
  };
}

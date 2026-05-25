# Shell aliases
{...}: {
  flake.modules.homeManager.shell = {...}: {
    home.shellAliases = {
      ls = "ls --color";
      ll = "ls -l";
      cd-flake = "cd \${NH_FLAKE}";
    };
  };
}

# Shell aliases
{...}: {
  flake.modules.homeManager.shell-alias = {...}: {
    key = "shell-alias#homeManager";
    config = {
      home.shellAliases = {
        ls = "ls --color";
        ll = "ls -l";
        cd-flake = "cd \${NH_FLAKE}";
      };
    };
  };
}

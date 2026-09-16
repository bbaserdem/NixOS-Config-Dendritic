# Smart directory navigation
{...}: {
  flake.modules.homeManager.shell-zoxide = {...}: {
    key = "shell-zoxide#homeManager";
    config = {
      programs.zoxide = {
        enable = true;
      };
    };
  };
}

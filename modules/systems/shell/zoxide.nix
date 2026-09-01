# Smart directory navigation
{...}: {
  flake.modules.homeManager.shell-zoxide = {...}: {
    programs.zoxide = {
      enable = true;
    };
  };
}

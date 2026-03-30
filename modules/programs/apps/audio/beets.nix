# Enabling beets
{...}: {
  flake.modules.homeManager.beets = {...}: {
    # Enable beets in userspace
    # The rest of the config should be user-specific
    programs.beets = {
      enable = true;
    };
  };
}

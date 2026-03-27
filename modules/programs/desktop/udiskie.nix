# Enabling udiskie service
{...}: {
  flake.modules.homeManager.udiskie = {...}: {
    # Enable beets in userspace
    # The rest of the config should be user-specific
    services.udiskie = {
      enable = true;
      tray = "always";
      notify = true;
      automount = false;
    };
  };
}

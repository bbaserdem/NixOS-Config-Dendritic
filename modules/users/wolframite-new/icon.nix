# User icon; host dependent (decrypts from secrets/assets/<username>_<icon>.bin)
{lib, ...}: {
  den = {
    # Establish defaults as a schema module
    schema.user = {
      config,
      lib,
      ...
    }: {
      config = lib.mkIf (config.name == "wolframite") {
        # Default user icon
        profile.icon = lib.mkDefault "skull";
      };
    };

    # Host Specific implementations
    hosts =
      {
        # yel-ana = "lensa";
        # su-ana = "headshot";
      }
      |> lib.mapAttrs (_: icon: {
        users.wolframite.profile.icon = icon;
      });
  };
}

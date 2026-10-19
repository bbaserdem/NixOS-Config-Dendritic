# Personal steam config
{...}: {
  flake.modules.homeManager.wolframite-steam = {
    pkgs,
    options,
    lib,
    ...
  }: {
    key = "wolframite-steam#homeManager";
    # With guard conditioning on existence of steam-config-nix module
    config =
      lib.optionalAttrs
      (lib.hasAttrByPath ["programs" "steam" "config"] options)
      {
        programs.steam.config = {
          # Game specific settings
          apps = {
            # Binding of isaac
            "250900" = {
              name = "Binding of Isaac";
              wrappers = ["gamemoderun"];
              # Options.ini defaults
              files.prefix.patch."drive_c/users/steamuser/My Documents/My Games/Binding of Isaac Repentance+/options.ini" = {
                format = "ini";
                content = {
                  Options = {
                    # Too dark by default;
                    Gamma = 1.5000;
                    # The HUD
                    FoundHUD = 1;
                    # UI sugar
                    ChargeBars = 1;
                    BulletVisibility = 1;
                    # Enable mouse control
                    MouseControl = 1;
                    # Console
                    EnableDebugConsole = 1;
                  };
                };
              };
            };
            # Slay the Spire 2
            "2868840" = {
              name = "Slay the Spire 2";
              wrappers = ["gamemoderun"];
            };
          };
        };
      };
  };
}

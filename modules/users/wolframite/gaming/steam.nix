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
          # Turn off steam to update config files on generation activation
          onSteamRunning = "close";
          # Default proton: use nixos' proton
          defaultCompatTool = pkgs.proton-ge-bin;
          # Create desktop entries by default
          desktopEntries.enable = true;

          # Game settings
          apps = {
            # Binding of isaac
            "000000" = {
              name = "Binding of Isaac";
              # TODO: Do this properly
              files.game.patch."config.ini" = {
                format = "ini";
                content = {
                  # TODO: Enable mouse and debug console
                  Video.Fullscreen = 1;
                };
              };
            };
          };
        };
      };
  };
}

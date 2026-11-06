# Personal steam config
{...}: let
  managedGames = {
    "Binding of Isaac" = 250900;
    "Slay the Spire 2" = 2868840;
    "Brotato" = 1942280;
    "Hades 2" = 1145350;
  };
in {
  flake.modules.homeManager.wolframite-steam = {
    options,
    lib,
    ...
  } @ args: {
    key = "wolframite-steam#homeManager";
    # With guard conditioning on existence of steam-config-nix module
    config =
      lib.optionalAttrs
      (lib.hasAttrByPath ["programs" "steam" "config"] options)
      (
        lib.mkMerge [
          {
            programs.steam.config.apps =
              managedGames
              |> lib.mapAttrs' (
                name: steamId:
                  lib.nameValuePair
                  (builtins.toString steamId)
                  {inherit name;}
              );
          }
          (
            lib.mkIf (args.osConfig.programs.gamemode.enable or false) {
              # Enable gamemode for each game I play
              programs.steam.config.apps =
                managedGames
                |> lib.mapAttrs' (
                  _: steamId:
                    lib.nameValuePair
                    (builtins.toString steamId)
                    {wrappers = ["gamemoderun"];}
                );
            }
          )
          {
            programs.steam.config = {
              # Game specific settings
              apps = {
                # Binding of isaac
                "250900" = {
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
                # Brotato
                "1942280" = {
                  # Memory leak bug; limit this with systemd
                  systemd = {
                    enable = true;
                    scope.properties = {
                      MemoryHigh = "10G";
                      MemoryMax = "24G";
                      MemorySwapMax = "1G";
                      OOMPolicy = "kill";
                    };
                  };
                };
              };
            };
          }
        ]
      );
  };
}

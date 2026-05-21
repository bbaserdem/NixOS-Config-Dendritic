# Gaming utilities
{...}: {
  flake.modules = {
    # Gaming modules

    # Nixos level integration
    nixos.gaming = {pkgs, ...}: {
      programs = {
        # Enable gamemode; system optimization
        gamemode = {
          enable = true;
          enableRenice = true;
        };
        # Enable opengamepadui; game dashboard
        opengamepadui = {
          enable = true;
          gamescopeSession = {
            enable = true;
          };
        };
      };
      # Need some userspace tools
      environment.systemPackages = with pkgs; [
        gamescope-wsi
        bubblewrap
      ];
    };

    # Home manager module for lutris on linux
    homeManager.gaming = {
      pkgs,
      lib,
      ...
    } @ args: {
      config = lib.mkMerge [
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            # Enable lutris
            programs.lutris = {
              enable = true;
            };
          }
        )
        (
          # If we are in HM as module in linux, pull steam from the OS module
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) (
            lib.optionalAttrs (lib.hasAttrByPath ["osConfig"] args) {
              programs.lutris.steamPackage = args.osConfig.programs.steam.package;
            }
          )
        )
      ];
    };
  };
}

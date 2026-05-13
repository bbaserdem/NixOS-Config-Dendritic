# Gaming utilities
{...}: {
  flake.modules = {
    # Gaming modules

    # Nixos level integration
    nixos.gaming = {pkgs, ...}: {
      programs = {
        # Enable steam
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          gamescopeSession.enable = true;
        };
        # Enable gamescope: steam session
        gamescope = {
          enable = true;
          capSysNice = true;
        };
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

    darwin.gaming = {pkgs, ...}: {
      # We install steam using brew
      homebrew.casks = [
        "steam"
        "steamcmd"
      ];
    };

    # Home manager module for lutris
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

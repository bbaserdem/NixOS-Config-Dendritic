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
      osConfig,
      pkgs,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          # Enable lutris
          programs.lutris = {
            enable = true;
            steamPackage = osConfig.programs.steam.package;
          };
        })
      ];
    };
  };
}

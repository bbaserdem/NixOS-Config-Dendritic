# Factory function for provisioning shared steam folder in linux
{...}: {
  flake = {
    modules = {
      # We install steam using brew in darwin
      darwin.gaming = {...}: {
        homebrew.casks = [
          "steam"
          "steamcmd"
        ];
      };
      # Steam setup in linux
      nixos.gaming = {...}: {
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
        };
        # Create the games group
        users.groups.games.name = "games";
        # Create a shared directory for steam common data
        systemd.tmpfiles.settings."20-steam-common" = {
          "/opt/steam-common" = {
            d = {
              user = "root";
              group = "games";
              mode = "2770";
            };
            "A+".argument = "g:games:rwX,m::rwX";
            "a+".argument = "d:g:games:rwx,d:m::rwx";
          };
        };
      };
    };
  };

  # Create a module addition to set bind mounts for user
  factory.steamUser = {user, ...}: {
    # Add user to the gaming group group
    nixos.${user} = {config, ...}: {
      users.users.${user}.extraGroups = [
        config.users.groups.games.name
      ];
    };
    # Create bind mounts for the user to use
    nixos.gaming = {
      config,
      lib,
      ...
    }: let
      userCfg = config.users.users.${user};
      dispatchCfg = {
        d = {
          user = user;
          group = userCfg.group;
          mode = "0755";
        };
      };
    in {
      config = lib.mkIf (userCfg.enable == true) {
        # Create the file hierarchy
        systemd.tmpfiles.settings."25-steam-${user}" = {
          "${userCfg.home}/.local" = dispatchCfg;
          "${userCfg.home}/.local/share" = dispatchCfg;
          "${userCfg.home}/.local/share/Steam" = dispatchCfg;
          "${userCfg.home}/.local/share/Steam/steamapps" = dispatchCfg;
          "${userCfg.home}/.local/share/Steam/steamapps/common" = dispatchCfg;
        };
        # Create bind mounts
        fileSystems."${userCfg.home}/.local/share/Steam/steamapps/common" = {
          device = "/opt/steam-common";
          fsType = "none";
          options = ["bind" "nofail"];
          depends = ["/opt/steam-common"];
        };
      };
    };
  };
}

# Communication apps using networks
{inputs, ...}: {
  # Dispatch modules in aspect
  den = {
    aspects.networking = {
      name = "networking";
      # Base dispatch
      provides.to-users = {
        user,
        host,
      }: {
        name = "networking(${user.userName}@${host.name})";
      };
      # Individual apps
      provides.signal = {
        name = "networking/signal";
        # Base dispatch
        provides.to-users = {
          user,
          host,
        }: {
          name = "networking/signal(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.signal-settings
            ];
          };
        };
      };
      provides.slack = {
        name = "networking/slack";
        # Base dispatch
        provides.to-users = {
          user,
          host,
        }: {
          name = "networking/slack(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.slack-settings
            ];
          };
        };
      };
      provides.zoom = {
        name = "networking/zoom";
        # Base dispatch
        provides.to-users = {
          user,
          host,
        }: {
          name = "networking/zoom(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.zoom-settings
            ];
          };
        };
      };
      provides.ferdium = {
        name = "networking/ferdium";
        # Base dispatch
        provides.to-users = {
          user,
          host,
        }: {
          name = "networking/ferdium(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.ferdium
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.homeManager = {
    signal-settings = {pkgs, ...}: {
      key = "signal#homeManager";
      config = {
        home.packages = with pkgs; [
          signal-desktop
        ];
      };
    };
    slack-settings = {pkgs, ...}: {
      key = "slack#homeManager";
      config = {
        home.packages = with pkgs; [
          slack
        ];
      };
    };
    zoom-settings = {pkgs, ...}: {
      key = "zoom#homeManager";
      config = {
        home.packages = with pkgs; [
          zoom-us
        ];
      };
    };
    ferdium = {
      pkgs,
      lib,
      ...
    }: {
      key = "ferdium#homeManager";
      config = {
        home.packages = with pkgs; (
          []
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            ferdium
          ])
        );
      };
    };
  };
}

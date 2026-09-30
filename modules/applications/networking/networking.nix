# Communication apps
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
              inputs.self.modules.homeManager.signal
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
              inputs.self.modules.homeManager.slack
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
              inputs.self.modules.homeManager.zoom
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

  # Audio editing tooling
  flake.modules.homeManager = {
    signal = {pkgs, ...}: {
      key = "signal#homeManager";
      config = {
        home.packages = with pkgs; [
          signal-desktop
        ];
      };
    };
    slack = {pkgs, ...}: {
      key = "slack#homeManager";
      config = {
        home.packages = with pkgs; [
          slack
        ];
      };
    };
    zoom = {pkgs, ...}: {
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
          ++ (lib.optionas pkgs.stdenv.hostPlatform.isLinux [
            ferdium
          ])
        );
      };
    };
  };
}

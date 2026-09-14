# Communication apps
{...}: {
  # Dispatch modules in aspect
  den = {
    aspects.collections = {
      provides.communication = {
      };
    };
  };

  # Audio editing tooling
  flake.modules.homeManager = {
    communication-signal = {pkgs, ...}: {
      key = "communication-signal#homeManager";
      config = {
        home.packages = [pkgs.signal-desktop];
      };
    };
    communication-slack = {pkgs, ...}: {
      key = "communication-slack#homeManager";
      config = {
        home.packages = [pkgs.slack];
      };
    };
    communication-zoom = {pkgs, ...}: {
      key = "communication-zoom#homeManager";
      config = {
        home.packages = [pkgs.zoom-us];
      };
    };
    communication-ferdium = {
      pkgs,
      lib,
      ...
    }: {
      key = "communication-ferdium#homeManager";
      config = lib.mkMerge [
        (
          lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
            home.packages = [pkgs.ferdium];
          }
        )
      ];
    };
  };
}

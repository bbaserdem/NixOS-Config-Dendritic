# Wolframite networking setup
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.networking
      ];

      # Networking aspect; parametric
      provides.networking = {
        host,
        user,
      }: {
        name = "wolframite/networking(${user.userName}@${host.name})";
        homeManager = {
          pkgs,
          lib,
          options,
          config,
          ...
        }: {
          # Modules to load
          imports = with inputs.self.modules.homeManager; [
            wolframite-firefox
            wolframite-librewolf
            wolframite-discord
          ];
          # Several configuration options
          config =
            lib.mkMerge [
            ];
        };
      };
    };
  };
}

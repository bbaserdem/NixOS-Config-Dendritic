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
        homeManager = {lib, ...}: {
          # Modules to load
          imports = with inputs.self.modules.homeManager; [
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

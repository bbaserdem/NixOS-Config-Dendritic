# Set personal gaming config entry point
{
  inputs,
  den,
  ...
}: {
  # User aspect that loads in gaming settings
  den = {
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.gaming
      ];

      # Gaming aspects
      provides.gaming = {
        host,
        user,
      }: {
        name = "wolframite/gaming(${user.userName}@${host.name})";
        homeManager = {...}: {
          # Beets is complicated; make it's own module
          imports = with inputs.self.modules.homeManager; [
            wolframite-steam
          ];
        };
      };
    };
  };
}

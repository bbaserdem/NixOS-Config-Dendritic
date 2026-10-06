# Wolframite documents setup
{
  inputs,
  den,
  ...
}: {
  # User aspect that loads in music related settings
  den = {
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.documents
      ];

      # Music aspect; parametric
      provides.documents = {
        host,
        user,
      }: {
        name = "wolframite/documents(${user.userName}@${host.name})";
        homeManager = {...}: {
          imports = with inputs.self.modules.homeManager; [
            wolframite-newsboat
            wolframite-obsidian
          ];
        };
      };
    };
  };
}

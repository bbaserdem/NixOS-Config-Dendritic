# Wolframite video setup
{
  inputs,
  den,
  ...
}: {
  # User aspect that loads in music related settings
  den = {
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.video
      ];

      # Music aspect; parametric
      provides.video = {
        host,
        user,
      }: {
        name = "wolframite/video(${user.userName}@${host.name})";
        homeManager = {...}: {
          imports = with inputs.self.modules.homeManager; [
            wolframite-ytdlp
          ];
        };
      };
    };
  };
}

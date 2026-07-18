# Initialize this user
{
  config,
  den,
  ...
}: let
  factory = config.factory;
in {
  den = {
    aspects.wolframite = {
      # Auto-includes
      includes = [
        den.aspects.wolframite.icons
      ];

      # Icons aspect
      icons = factory.mkUserIconAspect {
        default = "wolframite_lensa";
        hosts = {
          yel-ana = "wolframite_headshot";
        };
      };
    };
  };
}

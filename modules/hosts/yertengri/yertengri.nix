# Yertengri host entry point
{den, ...}: {
  den = {
    hosts.yertengri = {
      # System definition
      system = "x86_64-linux";

      # Enable styling
      stylix.enable = true;

      # Users
      users = {
        wolframite.classes = [
          "homeManager"
          "user"
        ];
        joeysaur.classes = [
          "homeManager"
          "user"
        ];
      };
    };

    # Base configuration
    aspects.yertengri = {
      # Base frameworks to subscribe to
      includes = with den.aspects; [
        secrets
      ];
    };
  };
}

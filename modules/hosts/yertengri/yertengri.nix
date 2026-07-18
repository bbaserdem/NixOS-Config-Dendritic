# Yertengri host entry point
{den, ...}: {
  den = {
    hosts.x86_64-linux.yertengri = {
      # Syncthing configuration
      syncthing = {
        enable = true;
        deviceId = "OGURLTB-BBT3MMT-CCK23PS-FT76672-YMWVY4T-6AR7LIO-22O6VN2-GJB3DAF";
      };

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
        disko
        secrets
      ];

      # Settings dispatched to users
      provides = {
        wolframite = {
          includes = [den.batteries.primary-user];
        };
        joeysaur = {
          includes = [den.batteries.primary-user];
        };
      };
    };
  };
}

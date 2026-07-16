# Yertengri host entry point
{den, ...}: {
  config = {
    den = {
      hosts.x86_64-linux.yertengri = {
        # Syncthing configuration
        syncthing = {
          enabled = true;
          deviceId = "OGURLTB-BBT3MMT-CCK23PS-FT76672-YMWVY4T-6AR7LIO-22O6VN2-GJB3DAF";
        };
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

      aspects.yertengri = {
        includes = with den.aspects; [
          disko
          secrets
        ];
      };
    };
  };
}

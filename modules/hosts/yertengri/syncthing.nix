# Yertengri host syncthing setup
{den, ...}: {
  den = {
    hosts.x86_64-linux.yertengri = {
      # Syncthing id
      syncthing.deviceId = "OGURLTB-BBT3MMT-CCK23PS-FT76672-YMWVY4T-6AR7LIO-22O6VN2-GJB3DAF";
    };

    # Enable syncthing aspect
    aspects.yertengri = {
      includes = [
        den.aspects.syncthing
      ];
    };
  };
}

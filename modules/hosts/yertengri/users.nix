# Users setup for yertengri
{...}: {
  den = {
    hosts.yertengri = {
      # Users
      users = {
        # Wolframite user host-specific settings
        wolframite = {
          classes = [
            "homeManager"
            "user"
            "games"
            "containerization"
            "virtualization"
          ];
          syncthing = {
            enable = true;
            id = "OGURLTB-BBT3MMT-CCK23PS-FT76672-YMWVY4T-6AR7LIO-22O6VN2-GJB3DAF";
          };
          usbAccess = true;
          uinput = true;
          stt = {
            enable = true;
            osd.enable = false;
          };
        };
        # Ben-Abuyah user host-specific settings
        ben-abuyah = {
          classes = [
            "homeManager"
            "user"
            "games"
          ];
          syncthing = {
            enable = true;
            id = "2FBNH7N-X62S3J2-65TEACZ-IZFATY5-BXJXR7O-ZT6ED6P-ZF4O6BV-A4RG3QE";
          };
          usbAccess = false;
          uinput = false;
        };
      };
    };
  };
}

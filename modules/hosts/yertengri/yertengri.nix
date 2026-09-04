# Yertengri host entry point
{den, ...}: {
  den = {
    hosts.yertengri = {
      # System definition
      system = "x86_64-linux";
      description = "Yertengri: Homestation PC";

      # Enable styling
      stylix.enable = true;

      # Boot settings
      boot = {
        configurationLimit = 10;
        loader = "grub";
      };

      # Users
      users = {
        # Wolframite user host-specific settings
        wolframite = {
          classes = [
            "homeManager"
            "user"
          ];
          syncthing = {
            enable = true;
            id = "OGURLTB-BBT3MMT-CCK23PS-FT76672-YMWVY4T-6AR7LIO-22O6VN2-GJB3DAF";
          };
        };
        # Ben-Abuyah user host-specific settings
        ben-abuyah = {
          classes = [
            "homeManager"
            "user"
          ];
          syncthing = {
            enable = true;
            id = "2FBNH7N-X62S3J2-65TEACZ-IZFATY5-BXJXR7O-ZT6ED6P-ZF4O6BV-A4RG3QE";
          };
        };
      };
    };

    # Base configuration
    aspects.yertengri = {
      # Base frameworks to subscribe to
      includes = with den.aspects; [
        secrets
        stylix
        # Get the extras from these modules
        nix-extra
        shell-extra
      ];
    };
  };
}

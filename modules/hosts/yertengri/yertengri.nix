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
        wolframite = {
          classes = [
            "homeManager"
            "user"
          ];
        };
        joeysaur = {
          classes = [
            "homeManager"
            "user"
          ];
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

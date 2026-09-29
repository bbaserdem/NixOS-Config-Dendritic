# Yertengri host entry point
{den, ...}: {
  den = {
    hosts.yertengri = {
      # System definition
      system = "x86_64-linux";
      description = "Yertengri: Homestation PC";

      # Features
      desktop = {
        enable = true;
        defaultSession = "plasma";
        geolocation = {
          enable = true;
          backend = "manual";
        };
      };
      networking = {
        enableLocalWeb = true;
      };
      stylix.enable = true;

      # Dev environment
      development = {
        enable = true;
        containerization = {
          enable = true;
          backend = "podman";
        };
        virtualization = {
          enable = true;
          windows = true;
        };
        secretspec = {
          enable = true;
          isGlobal = false;
        };
        direnv.enable = true;
        vcs = {
          enable = true;
          tools = ["git" "jujutsu"];
          providers = ["github" "forgejo" "gitlab"];
        };
        neovim = {
          enable = true;
          guiEnable = true;
        };
        agents = {
          enable = true;
          harnesses = [
            "claude"
            "opencode"
            "pi"
          ];
        };
      };

      # Boot settings
      boot = {
        configurationLimit = 10;
        loader = "grub";
      };

      # Gaming setup
      gaming = {
        enable = true;
        steam = {
          enable = true;
          share = true;
        };
      };

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

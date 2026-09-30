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
        geolocation = {
          enable = true;
          backend = "manual";
        };
      };
      hardware = {
        android = {
          enable = true;
          droidcam = true;
        };
        bluetooth.enable = true;
        fingerprint.enable = false;
        keyboards = {
          enable = true;
          qmk = true;
        };
        printing.enable = true;
        sidepulse.enable = false;
        yubikey.enable = true;
      };
      networking = {
        enableLocalWeb = true;
      };

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
          remotePlay = true;
          gamescope = true;
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

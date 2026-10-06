# Yertengri host entry point
{...}: {
  den = {
    hosts.yertengri = {
      # System definition
      system = "x86_64-linux";
      description = "Yertengri: Homestation PC";

      # Functionality
      sops.enable = true;
      audio.enable = true;

      # Boot settings
      boot = {
        configurationLimit = 10;
        loader = "grub";
      };

      # Shell settings
      shell = {
        default = "zsh";
      };

      # Desktop features
      desktop = {
        enable = true;
        geolocation = {
          enable = true;
          backend = "manual";
        };
        uinput.enable = true;
        fileBrowser = "dolphin";
        terminal = "kitty";
        stt = {
          enable = true;
          backend = "voxtype";
        };
      };

      # Hardware features
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
        graphics = {
          enable = true;
          vulkan = {
            enable = true;
          };
        };
      };

      # Network settings
      networking = {
        local.enable = true;
        zeroconf.enable = true;
        syncthing.relay = false;
        samba.enable = true;
      };

      # Tooling
      tools = {
        enable = true; # Gets everything
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

      # Gaming features
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
  };
}

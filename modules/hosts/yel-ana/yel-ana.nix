# Host definition for yel-ana
{...}: {
  den = {
    aspects.yel-ana = {
      name = "yel-ana";
    };

    # Entity record
    hosts.yel-ana = {
      system = "x86_64-linux";
      description = "Yel Ana: Wolframite's Laptop";

      # Functionality
      sops.enable = true;
      audio.enable = true;

      # Nix daemon related settings
      nix = {
        extras = true;
        defer = true;
      };

      # Boot settings
      boot = {
        configurationLimit = 5;
        loader = "limine";
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
        webBrowsers = [
          "librewolf"
          "firefox"
          "chromium"
        ];
        terminal = "kitty";
        stt = {
          enable = true;
          voxtype = {
            enable = true;
            backend = "whisper-vulkan";
          };
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
          nvidia.enable = false;
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
        languages = ["python" "lean"];
        containerization.enable = false;
        virtualization.enable = false;
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

      # Gaming
      gaming = {
        enable = true;
        steam = {
          enable = true;
          share = false;
          remotePlay = true;
          gamescope = true;
        };
      };
    };
  };
}

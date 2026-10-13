# Od-Ata host entry point
{...}: {
  den = {
    # Aspect key
    aspects.od-ata = {
      name = "od-ata";
    };

    # Entity record
    hosts.od-ata = {
      # System
      system = "x86_64-linux";
      description = "Od-Ata: Homelab PC";

      # Functionality is minimal
      sops.enable = true;
      audio.enable = true;

      # Nix settings
      nix = {
        extras = true;
        defer = false;
      };

      # Boot config
      boot = {
        configurationLimit = 5;
        loader = "limine";
      };

      # Shell
      shell = {
        default = "zsh";
      };

      # Features
      desktop = {
        enable = true;
        geolocation = {
          enable = true;
          backend = "manual";
        };
        uinput.enable = false;
        webBrowsers = [
          "librewolf"
        ];
        terminal = "kitty";
        stt.enable = false;
      };

      # Hardware
      hardware = {
        android.enable = false;
        bluetooth.enable = false;
        fingerprint.enable = false;
        keyboards.enable = false;
        printing.enable = true;
        sidepulse.enable = false;
        yubikey.enable = true;
        graphics = {
          enable = true;
          # TODO: DO this for od-ata
        };
      };

      # Networking
      networking = {
        local.enable = true;
        zeroconf.enable = true;
        syncthing.relay = false;
        samba.enable = true;
      };

      # Tooling
      tools.enable = true;

      # Development
      development = {
        enable = true;
        languages = [];
        containerization.enable = false;
        virtualization.enable = false;
        secretspec.enable = false;
        direnv.enable = true;
        vcs = {
          enable = true;
          tools = ["git" "jujutsu"];
          providers = [];
        };
        neovim = {
          enable = true;
          guiEnable = false;
        };
        agents.enable = false;
      };

      # Gaming
      gaming.enable = false;
    };
  };
}

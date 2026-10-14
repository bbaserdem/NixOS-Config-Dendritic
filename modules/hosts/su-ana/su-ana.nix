# Flake-parts config for su-ana
{...}: {
  den = {
    aspects.su-ana = {
      name = "su-ana";
    };

    hosts.su-ana = {
      # System definition
      system = "aarch64-darwin";
      description = "Su Ana: Wolframite's MBP";

      # Functionality
      sops.enable = true;
      nix = {
        extras = true;
        defer = false;
      };
      shell = {default = "zsh";};

      # Desktop features
      desktop = {
        enable = true;
        webBrowsers = [
          "librewolf"
          "google-chrome"
        ];
        terminal = "ghostty";
        stt.enable = false;
      };

      # Hardware stuff
      hardware = {
        yubikey.enable = true;
      };

      # Networking
      networking = {
        local.enable = true;
      };

      # System tools
      tools.enable = true;

      # Dev tools
      development = {
        enable = true;
        languages = ["python" "lean" "typescript"];
        containerization = {
          enable = true;
          backend = "orbstack";
        };
        virtualization = {
          enable = true;
          hypervisor = "virtualbuddy";
        };
        secretspec = {
          enable = true;
          isGlobal = true;
        };
        direnv.enable = true;
        vcs = {
          enable = true;
          tools = ["git" "jujutsu"];
          providers = ["github"];
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
          ];
        };
      };

      # No gaming on the work laptop
      gaming.enable = false;
    };
  };
}

# Opencode setup
{inputs, ...}: {
  # TODO: Do stylix theming with den
  # TODO: Check out opencode2

  # Modules
  flake.modules.darwin.llm-opencode-gui = {...}: {
    key = "llm-opencode-gui#darwin";
    config = {
      # Gui app for opencode
      homebrew.casks = ["opencode-desktop"];
    };
  };

  flake.modules.homeManager.llm-opencode-gui = {
    pkgs,
    lib,
    ...
  }: {
    key = "llm-opencode-gui#homeManager";
    # Gui app for opencode, only on linux (not working in darwin)
    config = lib.mkMerge [
      (
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        {
          home.packages = with pkgs; [
            llm-agents.opencode-desktop
          ];
        }
      )
    ];
  };

  flake.modules.homeManager.llm-opencode = {pkgs, ...}: {
    key = "llm-opencode#homeManager";
    config = {
      programs.opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;

        # Agentic setup
        context = inputs.self + /assets/ai/AGENTS.md;
        agents = inputs.self + /assets/ai/agents;
        commands = inputs.self + /assets/ai/commands;
        skills = inputs.self + /assets/ai/skills;

        # Enable central mcp integration
        enableMcpIntegration = true;

        # Global settings
        settings = {
          autoupdate = "notify";
          share = "auto";
          snapshot = true;
          lsp = true;

          # Configure permissions for reading nix store
          permission = {
            external_directory = {
              # Nix locations
              "/nix/**" = "allow";
              "/run/current-system/**" = "allow";
              # Credentials
              "~/.ssh/**" = "deny";
              "~/.gnupg/**" = "deny";
              "~/.config/sops-nix/**" = "deny";
              "~/Library/Keychains/**" = "deny";
              "/private/var/run/secrets/**" = "deny";
              "/var/lib/sops-nix/**" = "deny";
            };
            edit = {
              "/nix/**" = "deny";
              "/run/current-system/**" = "deny";
              "/etc/**" = "deny";
              "~/.config/**" = "deny";
            };
          };
        };
      };

      # Disable auto-lsp downloads
      home.sessionVariables = {
        OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
        OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
        OPENCODE_ENABLE_EXA = 1;
        OPENCODE_DISABLE_CLAUDE_CODE = 1;
      };
    };
  };
}

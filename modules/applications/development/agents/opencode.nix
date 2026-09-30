# Opencode setup
# TODO: Check out opencode2
{inputs, ...}: {
  den = {
    aspects.development = {
      provides.agents = {
        provides.opencode = {
          name = "development/agents/opencode";
          provides.to-users = {
            user,
            host,
          }: {
            name = "development/agents/opencode(${user.userName}@${host.name})";
            darwin = {...}: {
              imports = [
                inputs.self.modules.darwin.agents-opencode
              ];
            };
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.agents-opencode
              ];
            };
            # Stylix theming
            stylix = {
              targets.opencode = {
                enable = true;
                colors.enable = true;
              };
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    darwin.agents-opencode = {...}: {
      key = "agents-opencode#darwin";
      config = {
        # Gui app for opencode; from brew
        homebrew.casks = ["opencode-desktop"];
      };
    };

    homeManager.agents-opencode = {
      pkgs,
      lib,
      ...
    }: {
      key = "agents-opencode#homeManager";
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
                # Agent locations
                "~/.agent/**" = "allow";
              };
              edit = {
                "/nix/**" = "deny";
                "/run/current-system/**" = "deny";
                "/etc/**" = "deny";
                "~/.config/**" = "deny";
                # Allow external writes here
                "~/.agent/**" = "allow";
              };
            };
          };
        };

        # Modulate some features; mostly LSP
        home.sessionVariables = {
          OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
          OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
          OPENCODE_ENABLE_EXA = 1;
          OPENCODE_DISABLE_CLAUDE_CODE = 1;
        };

        # Install desktop app as well; but only in linux
        home.packages = with pkgs; (
          [
          ]
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            llm-agents.opencode-desktop
          ])
        );
      };
    };
  };
}

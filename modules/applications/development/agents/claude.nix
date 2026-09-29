# Claude code base setup
{
  inputs,
  lib,
  ...
}: {
  # Aspect
  den = {
    aspects.development = {
      provides.agents = {
        provides.claude = {
          name = "development/agents/claude";
          provides.to-users = {
            user,
            host,
          }: {
            name = "development/agents/claude(${user.userName}@${host.name})";
            darwin = {...}: {
              imports = [
                inputs.self.modules.darwin.agents-claude
              ];
            };
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.agents-claude
              ];
              # Add user custom spinner verbs to claude
              config = lib.mkIf (user.agents.spinners != null) {
                programs.claude-code.settings.spinnerVerbs = {
                  mode = "replace";
                  verbs = user.agents.spinners;
                };
              };
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    darwin.agents-claude = {...}: {
      key = "agents-claude#darwin";
      config = {
        # Gui app for claude
        homebrew.casks = ["claude"];
      };
    };

    homeManager.agents-claude = {
      pkgs,
      lib,
      ...
    }: {
      key = "agents-claude#homeManager";
      config = {
        programs.claude-code = {
          enable = true;
          package = pkgs.llm-agents.claude-code;

          # Agentic setup from this flake
          context = inputs.self + /assets/ai/AGENTS.md;
          hooksDir = inputs.self + /assets/ai/claude/hooks;
          agentsDir = inputs.self + /assets/ai/agents;
          commandsDir = inputs.self + /assets/ai/commands;
          rulesDir = inputs.self + /assets/ai/rules;

          # Enable central mcp integration
          enableMcpIntegration = true;

          # Global settings
          settings = {
            # Disable commit message
            includeCoAuthoredBy = false;
            # Auto-mode by default
            permissions.defaultMode = "auto";
          };
        };

        # Install desktop app as well; but only in linux
        home.packages = with pkgs; (
          [
          ]
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            llm-agents.claude-desktop
          ])
        );
      };
    };
  };
}

# Codex setup
{inputs, ...}: {
  # Den aspect
  den = {
    aspects.development = {
      provides.agents = {
        provides.codex = {
          name = "development/agents/codex";
          provides.to-users = {
            user,
            host,
          }: {
            name = "development/agents/codex(${user.userName}@${host.name})";
            darwin = {...}: {
              imports = [
                inputs.self.modules.darwin.agents-codex
              ];
            };
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.agents-codex
              ];
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    darwin.agents-codex = {...}: {
      key = "agents-codex#darwin";
      config = {
        # Gui app for codex is chatgpt
        homebrew.casks = ["chatgpt"];
      };
    };

    homeManager.agents-codex = {
      pkgs,
      lib,
      ...
    }: {
      key = "agents-codex#homeManager";
      config = {
        programs.codex = {
          enable = true;
          package = pkgs.llm-agents.codex;

          # Agentic setup
          context = inputs.self + /assets/ai/AGENTS.md;
          skills = inputs.self + /assets/ai/skills;
          rules = inputs.self + /assets/ai/rules;

          # Enable central mcp integration
          enableMcpIntegration = true;

          # Global settings
          settings = {
          };
        };

        # Install desktop app as well; but only in linux
        home.packages = with pkgs; (
          [
          ]
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            llm-agents.chatgpt
          ])
        );
      };
    };
  };
}

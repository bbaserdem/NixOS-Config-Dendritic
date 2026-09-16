# Claude code base setup
{inputs, ...}: {
  flake.modules.darwin.llm-claude-gui = {...}: {
    key = "llm-claude-gui#darwin";
    config = {
      # Gui app for claude
      homebrew.casks = ["claude"];
    };
  };

  flake.modules.homeManager.llm-claude = {
    pkgs,
    lib,
    config,
    ...
  }: {
    key = "llm-claude#homeManager";
    config = lib.mkMerge [
      {
        programs.claude-code = {
          enable = true;
          package = pkgs.llm-agents.claude-code;

          # Agentic setup
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
      }
      (
        # Do custom spinner verbs if able to and requested
        lib.optionalAttrs (config.local ? llm) (
          lib.mkIf ((config.local.llm.spinners or null) != null) {
            programs.claude-code.settings.spinnerVerbs = {
              mode = "replace";
              verbs = config.local.llm.spinners;
            };
          }
        )
      )
    ];
  };
}

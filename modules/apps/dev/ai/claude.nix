# Claude code global setup
{inputs, ...}: {
  flake.modules = {
    # Desktop app for darwin
    darwin.ai-claude = {...}: {
      homebrew.casks = [
        # Pull the desktop app
        "claude"
      ];
    };

    # Install claude-code
    homeManager.ai-claude = {pkgs, ...}: {
      # Enable claude code config without installing it ourselves
      programs.claude-code = {
        enable = true;
        package = pkgs.llm-agents.claude-code;

        # Global settings
        settings = {
          includeCoAuthoredBy = false;
        };

        # Agentic setup
        context = inputs.self + /assets/ai/AGENTS.md;
        hooksDir = inputs.self + /assets/ai/claude/hooks;
        agentsDir = inputs.self + /assets/ai/commands;
        commandsDir = inputs.self + /assets/ai/commands;
        rulesDir = inputs.self + /assets/ai/rules;

        enableMcpIntegration = true;
      };

      # Include our claude-statusline scripts
      home.packages = with pkgs; [
        local.claude-statusline
      ];
    };
  };
}

# Claude code global setup
{inputs, ...}: {
  flake.modules = {
    darwin.ai = {...}: {
      homebrew.casks = [
        # "claude-code@latest"
        "claude"
      ];
    };
    homeManager.ai = {
      pkgs,
      config,
      ...
    }: {
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
    };
  };
}

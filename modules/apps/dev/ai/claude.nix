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

        # Toolkits
        commandsDir = inputs.self + /assets/ai/commands;

        configDir = "${config.xdg.configHome}/claude";
        enableMcpIntegration = true;
        context = inputs.self + /assets/ai/AGENTS.md;
      };
    };
  };
}

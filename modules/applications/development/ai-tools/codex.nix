# Codex setup
{inputs, ...}: {
  flake.modules.darwin.llm-codex-gui = {...}: {
    key = "llm-codex-gui#darwin";
    config = {
      # Gui app for codex is chatgpt
      homebrew.casks = ["chatgpt"];
    };
  };

  flake.modules.homeManager.llm-codex = {pkgs, ...}: {
    key = "llm-codex#homeManager";
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
    };
  };
}

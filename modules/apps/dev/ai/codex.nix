# Codex global setup
{inputs, ...}: {
  flake.modules = {
    darwin.ai = {...}: {
      homebrew.casks = [
        "codex-app"
      ];
    };
    homeManager.ai = {pkgs, ...}: {
      programs.codex = {
        enable = true;
        package = pkgs.llm-agents.codex;

        settings = {
        };

        enableMcpIntegration = true;
        context = inputs.self + /assets/ai/AGENTS.md;
        rules = {};
        skills = {};
      };
    };
  };
}

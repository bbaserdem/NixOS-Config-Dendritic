# Codex global setup
{inputs, ...}: {
  flake.modules = {
    darwin.ai = {...}: {
      homebrew.casks = [
        # "codex"
        "codex-app"
      ];
    };
    homeManager.ai = {pkgs, ...}: {
      programs.codex = {
        enable = true;
        package = pkgs.llm-agents.codex;

        settings = {
        };

        # TODO: New options in 26.05
        # enableMcpIntegration = true;
        custom-instructions = builtins.readFile (inputs.self + /assets/ai/AGENTS.md);
        # context = inputs.self + /assets/ai/AGENTS.md;
        # rules = {};
        # skills = {};
      };
    };
  };
}

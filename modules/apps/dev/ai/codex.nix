# Codex global setup
{inputs, ...}: {
  flake.modules = {
    # Install desktop app in Darwin
    darwin.ai-codex = {...}: {
      homebrew.casks = [
        "codex-app"
      ];
    };

    # Codex install
    homeManager.ai-codex = {
      pkgs,
      lib,
      ...
    }: {
      programs.codex = {
        enable = true;
        package = pkgs.llm-agents.codex;
        # Agentic setup
        context = inputs.self + /assets/ai/AGENTS.md;
        skills = inputs.self + /assets/ai/skills;
        rules = let
          rulesDir = inputs.self + /assets/ai/rules;
        in
          rulesDir
          |> builtins.readDir
          |> lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name)
          |> lib.mapAttrs' (name: _: lib.nameValuePair (lib.removeSuffix ".md" name) (rulesDir + "/${name}"));

        settings = {
        };

        enableMcpIntegration = true;
      };
    };
  };
}

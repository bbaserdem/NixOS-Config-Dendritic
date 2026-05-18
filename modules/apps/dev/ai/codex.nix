# Codex global setup
{inputs, ...}: {
  flake-file.inputs = {
    codex-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
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
        package = inputs.codex-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;

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

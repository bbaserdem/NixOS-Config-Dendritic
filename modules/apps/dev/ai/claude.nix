# Claude code global setup
{inputs, ...}: {
  flake-file.inputs = {
    claude-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
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
        package = inputs.claude-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

        # Global settings
        settings = {
          includeCoAuthoredBy = false;
        };

        # Toolkits
        commandsDir = inputs.self + /assets/ai/commands;

        # TODO; New settings in 26.05
        # configDir = "${config.xdg.configHome}/claude";
        # enableMcpIntegration = true;
        # context = inputs.self + /assets/ai/AGENTS.md;
      };
    };
  };
}

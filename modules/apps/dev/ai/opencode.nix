# Opencode global setup
{inputs, ...}: {
  flake.modules = {
    # Install opencode through brew, but we will punt this in favor of  flake for now
    darwin.ai = {
      homebrew.brews = [
        # "opencode"
      ];
    };

    homeManager = {
      # Fetch up to date source from
      # Theming with stylix
      stylix = {...}: {
        stylix.targets.opencode = {
          enable = true;
          colors.enable = true;
        };
      };

      # OpenCode setup
      ai = {pkgs, ...}: {
        # Enable opencode code config without installing it ourselves
        programs.opencode = {
          enable = true;
          package = pkgs.llm-agents.opencode;
          # Agentic setup
          context = inputs.self + /assets/ai/AGENTS.md;
          agents = inputs.self + /assets/ai/agents;
          commands = inputs.self + /assets/ai/commands;
          skills = inputs.self + /assets/ai/skills;

          enableMcpIntegration = true;
          settings = {
            autoupdate = "notify";
            share = "auto";
            snapshot = true;
            lsp = true;
          };
        };

        # Disable auto-lsp downloads
        home.sessionVariables = {
          OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
          OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
          OPENCODE_ENABLE_EXA = 1;
          OPENCODE_DISABLE_CLAUDE_CODE = 1;
        };

        home.packages = [
          # inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode-desktop
        ];
      };
    };
  };
}

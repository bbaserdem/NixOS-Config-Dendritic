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
      ai = {
        config,
        pkgs,
        ...
      }: {
        # Enable opencode code config without installing it ourselves
        programs.opencode = {
          enable = true;
          package = pkgs.llm-agents.opencode;
          # Agentic setup
          agents = {};

          enableMcpIntegration = true;
          settings = {
            autoupdate = "notify";
            share = "auto";
            snapshot = true;
            lsp = true;
          };

          # TODO; New options in 26.05
          commands = inputs.self + /assets/ai/commands;
          context = inputs.self + /assets/ai/AGENTS.md;
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

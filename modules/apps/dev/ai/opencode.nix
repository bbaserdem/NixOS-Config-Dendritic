# Opencode global setup
{inputs, ...}: {
  flake.modules.homeManager = {
    # Theming with stylix
    stylix = {...}: {
      stylix.targets.opencode = {
        enable = true;
        colors.enable = true;
      };
    };
    # OpenCode setup
    ai = {...}: {
      # Enable opencode code config without installing it ourselves
      programs.opencode = {
        enable = true;
        package = null;
        # Agentic setup
        commands = {
          "_commit" = builtins.readFile (inputs.self + /assets/ai/commands/commit.md);
        };
        agents = {};
        rules = "";

        settings = {
          autoupdate = "notify";
          share = "auto";
          snapshot = true;
        };
      };

      # Disable auto-lsp downloads
      home.sessionVariables = {
        OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
        OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
        OPENCODE_ENABLE_EXA = 1;
        OPENCODE_DISABLE_CLAUDE_CODE = 1;
      };
    };
  };
}

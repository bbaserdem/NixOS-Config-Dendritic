# Opencode global setup
{...}: {
  flake.modules = {
    homeManager.ai = {...}: {
      # Enable opencode code config without installing it ourselves
      programs.opencode = {
        enable = true;
        package = null;
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

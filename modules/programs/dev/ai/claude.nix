# Claude code global setup
{...}: {
  flake.modules.homeManager.claude = {...}: {
    # Enable claude code config without installing it ourselves
    programs.claude-code = {
      enable = true;
      package = null;

      # Global settings
      settings = {
        includeCoAuthoredBy = false;
      };
    };
  };
}

# Configuring AI tools
{...}: {
  flake.modules.homeManager.wolframite-claude = {pkgs, ...}: {
    key = "wolframite-claude#homeManager";
    config = {
      programs.claude-code = {
        settings = {
          # Statusline
          statusLine = {
            type = "command";
            command = "${pkgs.local.claude-statusline}/bin/claude-statusline-wolframite";
            padding = 0;
            refreshInterval = 5;
          };
          # Permissive mode
          permissions.defaultMode = "auto";
        };
      };
    };
  };
}

# Add codegraph as global mcp tool
{...}: {
  flake.modules.homeManager.llm-codegraph = {pkgs, ...}: {
    key = "llm-codegraph#homeManager";
    config = {
      # Install to user profile
      home.packages = with pkgs; [
        llm-agents.codegraph
      ];

      # Add to global mcp servers
      programs.mcp.servers.codegraph = {
        type = "stdio";
        command = "${pkgs.llm-agents.codegraph}/bin/codegraph";
        enabled = true;
        args = [
          "serve"
          "--mcp"
        ];
      };

      # Specific hooks for software
      # Give claude permissions
      programs.claude-code.settings = {
        permissions = {
          allow = [
            "mcp__codegraph__*"
          ];
        };
      };
    };
  };
}

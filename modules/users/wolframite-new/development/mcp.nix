# Configuring AI tools
{inputs, ...}: {
  den = {
    # Set aspect default
    schema.user = {
      config,
      lib,
      ...
    }: {
      config = lib.mkIf (config.name == "wolframite") {
        agents.spinners = "kaomoji";
      };
    };
  };

  # Module setup
  flake.modules.homeManager.wolframite-mcp = {...}: {
    key = "wolframite-mcp";
    config = {
      programs = {
        # MCP Servers
        mcp.servers = {
          grep-mcp = {
            url = "https://mcp.grep.app";
          };
          context7 = {
            url = "https://mcp.context7.com/mcp";
            headers = {
              "CONTEXT7_API_KEY" = "{env:CONTEXT7_API_KEY}";
            };
          };
        };
      };
    };
  };
}

# Configuring AI tools
{inputs, ...}: {
  flake.modules.homeManager.batuhan = {...}: {
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

# Set up MCP's for general usage across ai toolkits and projects
{...}: {
  flake.modules = {
    homeManager.ai = {
      lib,
      pkgs,
      ...
    }: {
      config = lib.mkMerge [
        {
          programs.mcp = {
            enable = true;
            servers = {
              vercel-grep-mcp = {
                url = "https://mcp.grep.app";
              };
              context7 = {
                type = "remote";
                url = "https://mcp.context7.com/mcp";
                headers = {
                  "CONTEXT7_API_KEY" = "{env:CONTEXT7_API_KEY}";
                };
              };
            };
          };
        }
        (
          # Darwin-only MCP servers
          lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
            programs.mcp.servers = {
            };
          }
        )
      ];
    };
  };
}

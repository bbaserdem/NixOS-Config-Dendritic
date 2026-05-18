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
            };
          };
        }
        (
          # Darwin-only MCP servers
          lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
            programs.mcp.servers = {
              repoprompt = {
                command = "/Applications/Repo Prompt.app/.../repoprompt-mcp";
                args = [];
              };
            };
          }
        )
      ];
    };
  };
}

# AI tools global setup
{...}: {
  flake = {
    modules = {
      darwin.ai = {...}: {
        # Enable userspace tools
        homebrew = {
          casks = [
            # External context tools
          ];
        };
      };

      homeManager.ai = {...}: {
        # Global MCP config
        programs.mcp.enable = true;
      };
    };
  };
}

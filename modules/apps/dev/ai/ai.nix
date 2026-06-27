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

      homeManager.ai = {pkgs, ...}: {
        # Global MCP config
        programs.mcp = {
          enable = true;
          # Globally enabled MCP servers
          servers = {
            nix = {
              command = "${pkgs.unstable.mcp-nixos}/bin/mcp-nixos";
            };
          };
        };
      };
    };
  };
}

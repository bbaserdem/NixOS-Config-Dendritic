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

      homeManager.ai = {pkgs, ...}: let
        nixosMcp = pkgs.unstable.mcp-nixos;
      in {
        # Global MCP config
        programs.mcp = {
          enable = true;
          # Globally enabled MCP servers
          servers = {
            nix = {
              command = "${nixosMcp}/bin/mcp-nixos";
            };
          };
        };
        # Install MCP server
        home.packages = [
          nixosMcp
        ];
      };
    };
  };
}

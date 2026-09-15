# AI tools global setup
{inputs, ...}: {
  flake = {
    modules = {
      darwin.ai = {...}: {
        # Enable userspace tools
        homebrew = {
          casks = [
            # External context tools
            "perplexity"
            "wispr-flow"
            "granola"
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
              enabled = true;
              command = "${pkgs.unstable.mcp-nixos}/bin/mcp-nixos";
            };
          };
        };
      };

      homeManager.ai-sidepulse = {...}: {
        imports = [
          inputs.self.modules.homeManager.sidepulse-module
          inputs.self.modules.homeManager.sidepulse-settings
          inputs.self.modules.homeManager.sidepulse-claude
        ];
      };
    };
  };
}

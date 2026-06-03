# AI tools global setup
{inputs, ...}: {
  flake-file = {
    nixConfig = {
      extra-substituters = [
        "https://cache.numtide.com"
      ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
    inputs.llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  # Apply our nixpkgs overlay
  localConfig.nixpkgs.overlays = [
    inputs.llm-agents.overlays.default
  ];

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
        programs.mcp.enable = true;
        # Harnesses
        home.packages = with pkgs.llm-agents; [
          forgecode
          droid
        ];
      };
    };
  };
}

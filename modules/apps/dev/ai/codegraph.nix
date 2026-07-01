# Codegraph mcp tools
{...}: {
  flake.modules.homeManager.ai-codegraph = {pkgs, ...}: let
    codegraph = pkgs.llm-agents.codegraph;
    codegraph-bin = "${codegraph}/bin/codegraph";
  in {
    # Install tool to user profile
    home.packages = [
      codegraph
    ];

    # Install the MCP globally
    programs.mcp.servers.codegraph = {
      type = "stdio";
      command = codegraph-bin;
      enabled = false;
      args = [
        "serve"
        "--mcp"
      ];
    };

    # Install claude hooks
    programs.claude-code.settings = {
      hooks = {
        UserPromptSubmit = [
          {
            hooks = [
              {
                type = "command";
                command = "${codegraph-bin} prompt-hook";
              }
            ];
          }
        ];
      };
      permissions = {
        allow = [
          "mcp__codegraph__*"
        ];
      };
    };
  };
}

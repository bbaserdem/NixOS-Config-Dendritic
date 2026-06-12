# Configuring AI tools
{inputs, ...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    pkgs,
    ...
  }: let
    spinnerList =
      (inputs.self + /assets/ai/spinners-kaomoji.txt)
      |> builtins.readFile
      |> (lib.splitString "\n")
      |> (map lib.trim)
      |> (builtins.filter (line: line != ""));
  in {
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

        # Claude code settings
        claude-code = {
          settings = {
            # Custom spinners
            spinnerVerbs = {
              mode = "replace";
              verbs = spinnerList;
            };
            # Statusline
            statusLine = {
              type = "command";
              command = "${pkgs.local.claude-statusline}/bin/claude-statusline-wolframite";
              padding = 0;
              refreshInterval = 5;
            };
          };
        };
      };
    };
  };
}

# Configuring AI tools
{inputs, ...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    pkgs,
    ...
  }: let
    spinnerText = builtins.readFile (inputs.self + /assets/wolframite/spinners.txt);
    spinnerList = lib.pipe spinnerText [
      (lib.splitString "\n")
      (map lib.trim)
      (builtins.filter (line: line != ""))
    ];
  in {
    config = lib.mkMerge [
      {
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
            playwright = {
              command = "mcp-server-playwright";
            };
          };

          # Claude code settings
          claude-code = {
            settings = {
              spinnerVerbs = {
                mode = "replace";
                verbs = spinnerList;
              };
            };
          };
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
        }
      )
    ];
  };
}

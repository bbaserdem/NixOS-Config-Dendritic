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
      programs.claude-code = {
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
          # Permissive mode
          defaultModel = "auto";
        };
      };
    };
  };
}

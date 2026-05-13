# Configuring AI tools
{inputs, ...}: {
  flake.modules.homeManager.batuhan = {lib, ...}: let
    spinnerText = builtins.readFile (inputs.self + /assets/wolframite/spinners.txt);
    spinnerList = lib.pipe spinnerText [
      (lib.splitString "\n")
      (map lib.trim)
      (builtins.filter (line: line != ""))
    ];
  in {
    programs = {
      claude-code = {
        settings = {
          spinnerVerbs = {
            mode = "replace";
            verbs = spinnerList;
          };
        };
      };
    };
  };
}

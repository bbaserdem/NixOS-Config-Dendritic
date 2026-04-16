# Configuring AI tools
{...}: {
  flake.modules.homeManager.batuhan = {lib, ...}: let
    spinnerText = builtins.readFile ./spinners.txt;
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

# Language sources
{...}: {
  flake.modules.homeManager.wolframite = {pkgs, ...}: {
    # Need turkish and english
    home.packages = with pkgs; [
      (
        hunspell.withDicts (d:
          with d; [
            en_US
            tr_TR
          ])
      )
    ];
  };
}

# Language sources
{...}: {
  flake.modules.homeManager.batuhan = {pkgs, ...}: {
    # Need turkish and english
    home.packages = with pkgs; [
      (
        hunspell.withDicts (d: [
          en_US
          tr_TR
        ])
      )
    ];
  };
}

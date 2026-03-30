# Language sources
{...}: {
  flake.modules.homeManager.batuhan = {pkgs, ...}: {
    # Need turkish and english
    home.packages = with pkgs; [
      (
        hunspellWithDicts (with hunspellDicts; [
          en_US
          tr_TR
        ])
      )
    ];
  };
}

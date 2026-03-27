# Our languages for spellchecking
{...}: {
  flake.modules.homeManager.batuhan = {pkgs, ...}: {
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

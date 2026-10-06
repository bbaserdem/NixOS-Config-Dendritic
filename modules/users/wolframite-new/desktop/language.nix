# Languages to add
{...}: {
  flake.modules.homeManager.wolframite-language = {
    pkgs,
    lib,
    ...
  }: {
    key = "wolframite-language#homeManager";
    config = {
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
  };
}

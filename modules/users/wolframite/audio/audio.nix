# General audio settings
{inputs, ...}: {
  flake.modules.homeManager.wolframite = {pkgs, ...}: {
    imports = [
      inputs.self.modules.homeManager.beets-wolframite
    ];

    config = {
      # Install our script packgae
      home.packages = with pkgs; [
        local.audman
      ];
    };
  };
}

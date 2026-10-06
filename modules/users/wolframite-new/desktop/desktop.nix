# Wolframite desktop setup
{
  inputs,
  den,
  ...
}: {
  # User aspect that loads in music related settings
  den = {
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.desktop
      ];

      # Music aspect; parametric
      provides.desktop = {
        host,
        user,
      }: {
        name = "wolframite/desktop(${user.userName}@${host.name})";
        homeManager = {lib, ...}: {
          # Beets is complicated; make it's own module
          imports = with inputs.self.modules.homeManager; [
            wolframite-keymap
            wolframite-language
            wolframite-kitty
            wolframite-ghostty
          ];
          # Several configuration options
          config =
            lib.mkMerge [
            ];
        };
      };
    };
  };
}

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
        homeManager = {
          lib,
          pkgs,
          config,
          ...
        }: {
          # Beets is complicated; make it's own module
          imports = with inputs.self.modules.homeManager; [
            wolframite-keymap
            wolframite-language
            wolframite-kitty
            wolframite-ghostty
            wolframite-gecko
            wolframite-firefox
            wolframite-librewolf
          ];
          # Several configuration options
          config = lib.mkMerge [
            ( # Default mime apps to use
              lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
                xdg = {
                  mimeApps.defaultApplicationPackages =
                    []
                    ++ ( # Browser should default to librewolf
                      lib.optional
                      config.programs.librewolf.enable
                      config.programs.librewolf.finalPackage
                    );
                };
              }
            )
          ];
        };
      };
    };
  };
}

# Man pager
{...}: {
  flake.modules.homeManager = {
    # Enable bat stylix theme
    stylix = {...}: {
      stylix.targets.bat.enable = true;
    };

    # Man page setup
    shell = {
      pkgs,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        {
          # Enable home-manager man page
          manual.manpages.enable = true;

          programs = {
            # Enable man pages
            man.enable = true;

            # Enable bat to be pager
            bat = {
              enable = true;
              extraPackages = with pkgs.bat-extras; [
                prettybat
                batwatch
                batpipe
                batman
                batgrep
                batdiff
              ];
            };
          };

          # Set bat to be the pager
          home.sessionVariables = {
            MANPAGER = "sh -c 'col -bx | bat --language=man --plain'";
            MANROFFOPT = "-c";
          };
        }
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            programs.man = {
              package = pkgs.man;
              generateCaches = true;
            };
          }
        )
        (
          # GNU man dependency binaries don't work in darwin
          lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
            programs.man.package = null;
          }
        )
      ];
    };
  };
}

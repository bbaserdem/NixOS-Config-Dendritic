# Man pager
{...}: {
  flake.modules.homeManager = {
    # Enable bat stylix theme
    stylix = {...}: {
      stylix.targets.bat.enable = true;
    };

    # Man page setup
    shell = {pkgs, ...}: {
      # Enable home-manager man page
      manual.manpages.enable = true;

      programs = {
        # Enable man pages
        man = {
          enable = true;
          generateCaches = true;
        };

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
    };
  };
}

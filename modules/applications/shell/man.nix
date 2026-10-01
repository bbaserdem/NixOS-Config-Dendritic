# Man pager
{
  inputs,
  den,
  ...
}: {
  den = {
    # Schema registry; dispatch this always
    schema = {
      host.includes = [den.aspects.shell._.man];
    };

    # Aspect
    aspects.shell = {
      provides.man = {
        name = "shell/man";
        provides.to-users = {
          host,
          user,
        }: {
          name = "shell/man(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.shell-man
            ];
          };
          stylix = {
            targets.bat = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Man page setup
  flake.modules.homeManager.shell-man = {
    pkgs,
    lib,
    ...
  }: {
    key = "shell-man#homeManager";
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
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          programs.man = {
            package = pkgs.man;
            generateCaches = true;
          };
        }
      )
      (
        # GNU man dependency binaries don't work in darwin
        lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          programs.man.package = null;
        }
      )
    ];
  };
}

# Direnv setup
{...}: {
  flake.modules.homeManager.shell = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        # Enable direnv for our shells
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          config = {
            global = {
              load_dotenv = false;
              warn_timeout = "0";
            };
          };
        };

        # Reformat direnv output to be muted
        home.sessionVariables = let
          logFormat = "\"$(printf '\\033[2;1;3mdirenv:\\033[22;23m %%s\\033[0m')\"";
        in {
          "DIRENV_LOG_FORMAT" = logFormat;
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          # On nixpkgs-25.11 darwin of direnv is broken, pull from unstable
          programs.direnv.packages = pkgs.unstable.direnv;
        }
      )
    ];
  };
}

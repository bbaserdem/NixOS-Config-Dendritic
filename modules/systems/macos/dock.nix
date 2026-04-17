# Configuring macos dock, without hard-coding
# Original source: https://gist.github.com/antifuchs/10138c4d838a63c0a05e725ccd7bccdd
{...}: {
  flake.modules.darwin.macos = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.macos.dock;
  in {
    # Define our options
    options = {
      macos.dock = {
        # Enable flag
        enable = lib.mkOption {
          description = "Enable dock config";
          default = pkgs.stdenv.hostPlatform.isDarwin;
        };
        # Entry list
        entries = lib.mkOption {
          description = "Entries on the Dock";
          type = with lib.types;
            listOf (submodule {
              options = {
                path = lib.mkOption {type = str;};
                section = lib.mkOption {
                  type = str;
                  default = "apps";
                };
                options = lib.mkOption {
                  type = str;
                  default = "";
                };
              };
            });
          readOnly = true;
        };
        username = lib.mkOption {
          description = "Username to apply the dock settings to";
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
    };

    config = lib.mkIf (cfg.enable && (cfg.username != null)) (
      let
        dockutil = "${pkgs.dockutil}/bin/dockutil";
        normalize = path:
          if lib.hasSuffix ".app" path
          then path + "/"
          else path;
        entryURI = path:
          "file://"
          + (
            builtins.replaceStrings
            [" " "!" "\"" "#" "$" "%" "&" "'" "(" ")"]
            ["%20" "%21" "%22" "%23" "%24" "%25" "%26" "%27" "%28" "%29"]
            (normalize path)
          );
        wantURIs = lib.concatMapStrings (entry: "${entryURI entry.path}\n") cfg.entries;
        createEntries =
          lib.concatMapStrings
          (
            entry: "${pkgs.dockutil}/bin/dockutil --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options}\n"
          )
          cfg.entries;
      in {
        system.activationScripts.postActivation.text = ''
          echo >&2 "Setting up the Dock for ${cfg.username}..."
          su ${cfg.username} -s /bin/sh <<'USERBLOCK'
          haveURIs="$(${dockutil} --list | ${pkgs.coreutils}/bin/cut -f2)"
          if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 ; then
            echo >&2 "Resetting Dock."
            ${dockutil} --no-restart --remove all
            ${createEntries}
            killall Dock
          else
            echo >&2 "Dock setup complete."
          fi
          USERBLOCK
        '';
      }
    );
  };
}

# Dispatch existing sops-nix secret files into shell environment variables.
{...}: {
  flake.modules.homeManager.default = {
    config,
    lib,
    options,
    ...
  }: let
    cfg = config.local.sopsEnv;

    invalidEnvNames =
      config.local.sopsEnv
      |> lib.attrNames
      |> builtins.filter (name: builtins.match "[A-Za-z_][A-Za-z0-9_]*" name == null);

    missingSecrets =
      config.local.sopsEnv
      |> lib.attrValues
      |> builtins.filter (secret: ! builtins.hasAttr secret config.sops.secrets);

    secretPath = secret: config.sops.secrets.${secret}.path;
    shellPath = secret: lib.escapeShellArg (secretPath secret);
    nuPath = secret: builtins.toJSON (secretPath secret);

    mkLines = mkLine:
      cfg
      |> lib.mapAttrsToList mkLine
      |> lib.concatStringsSep "\n";

    posixExports = mkLines (env: secret: let
      path = shellPath secret;
    in ''
      if [ -r ${path} ] ; then
        export ${env}="$(cat ${path})"
      fi
    '');

    fishExports = mkLines (env: secret: let
      path = shellPath secret;
    in ''
      if test -r ${path}
        set -gx ${env} (cat ${path})
      end
    '');

    nushellExports = mkLines (env: secret: let
      path = nuPath secret;
    in ''
      do {
        let secret_path = ${path}
        if ($secret_path | path exists) {
            $env.${env} = (open $secret_path | str trim)
        }
      }
    '');
  in {
    options.local.sopsEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = ''
        Environment variables to populate from existing sops-nix secrets.
      '';
    };

    config = lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) (
      lib.mkIf (cfg != {}) (lib.mkMerge [
        {
          assertions = [
            {
              assertion = invalidEnvNames == [];
              message = "local.sopsEnv contains invalid environment variable names: ${lib.concatStringsSep ", " invalidEnvNames}";
            }
            {
              assertion = missingSecrets == [];
              message = "local.sopsEnv references missing sops.secrets entries: ${lib.concatStringsSep ", " missingSecrets}";
            }
          ];
        }

        (
          lib.mkIf config.programs.zsh.enable {
            programs.zsh.initContent = lib.mkOrder 2000 ''
              #--START--ZSH load sops env vars
              ${posixExports}
              #--END--ZSH load sops env vars
            '';
          }
        )

        (
          lib.mkIf config.programs.bash.enable {
            programs.bash.bashrcExtra = lib.mkOrder 2000 ''
              #--START--BASH load sops env vars
              ${posixExports}
              #--END--BASH load sops env vars
            '';
          }
        )

        (
          lib.mkIf config.programs.fish.enable {
            programs.fish.shellInitLast = lib.mkOrder 2000 ''
              #--START--FISH load sops env vars
              ${fishExports}
              #--END--FISH load sops env vars
            '';
          }
        )

        (lib.mkIf config.programs.nushell.enable {
          programs.nushell.extraEnv = lib.mkOrder 2000 ''
            #--START--NUSHELL load sops env vars
            ${nushellExports}
            #--END--NUSHELL load sops env vars
          '';
        })
      ])
    );
  };
}

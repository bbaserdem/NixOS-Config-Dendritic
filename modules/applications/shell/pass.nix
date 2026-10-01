# Password-store common config
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Schema registry
    schema = {
      host.includes = [den.aspects.shell.policies.pass-host-dispatch];
      user.includes = [den.aspects.shell.policies.pass-user-dispatch];
    };

    aspects.shell = {
      policies = {
        pass-host-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.pass);
        pass-user-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.pass._.to-users);
      };

      provides.pass = {
        name = "shell/pass";
        provides.to-users = {
          host,
          user,
        }: {
          name = "shell/pass(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.pass-settings
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.pass-settings = {
    config,
    pkgs,
    lib,
    ...
  }: {
    key = "pass-settings#homeManager";
    config = {
      programs.password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
          PASSWORD_STORE_CLIP_TIME = "30";
          PASSWORD_STORE_GENERATED_LENGTH = "16";
        };
        package = pkgs.pass.withExtensions (
          exts:
            [
              exts.pass-checkup
              exts.pass-genphrase
              exts.pass-update
            ]
            ++ (
              lib.optionals pkgs.stdenv.hostPlatform.isLinux
              [
                exts.pass-tomb # Not available in nix-darwin
              ]
            )
        );
      };
    };
  };
}

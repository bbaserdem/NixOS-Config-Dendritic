# SSH configuration for batuhan
{inputs, ...}: {
  flake.modules.homeManager.wolframite-ssh = {
    config,
    lib,
    options,
    ...
  }: {
    key = "wolframite-ssh#homeManager";
    config = lib.mkMerge [
      ( # Git providers ssh access
        let
          gitHosts = [
            "github.com"
            "gitlab.com"
            "codeberg.org"
          ];
        in {
          programs.ssh.settings = lib.genAttrs gitHosts (
            h: {
              user = lib.mkDefault "git";
              hostname = lib.mkDefault h;
              identitiesOnly = lib.mkDefault true;
              IdentityFile = lib.mkDefault (
                config.home.homeDirectory
                + "/.ssh/id_ed25519_"
                + "${h |> builtins.split "\\." |> builtins.head |> lib.toUpper}"
              );
            }
          );
        }
      )
      ( # Import liveusb and remote hosts ssh access, if sops is enabled
        lib.optionalAttrs (options ? sops) (
          lib.mkMerge [
            (
              let
                myHosts = ["kayra" "mergen" "od-ata"];
              in {
                # Dispatch the ssh keys
                sops.secrets = lib.genAttrs' myHosts (
                  h:
                    lib.nameValuePair
                    "ssh/${h}"
                    {
                      sopsFile = inputs.self + /secrets/user/secrets.yaml;
                      path = "${config.home.homeDirectory}/.ssh/id_ed25519_${lib.toUpper h}";
                      mode = "0600";
                    }
                );
                # Put the keys in the SSH configuration
                programs.ssh.settings = lib.genAttrs myHosts (
                  h: {
                    user = lib.mkDefault "root";
                    hostname = "${h}.local";
                    IdentityFile = "${config.sops.secrets."ssh/${h}".path}";
                    identitiesOnly = true;
                  }
                );
              }
            )
            {
              # Override some defaults from above
              programs.ssh.settings."od-ata".user = "wolframite";
            }
          ]
        )
      )
    ];
  };
}

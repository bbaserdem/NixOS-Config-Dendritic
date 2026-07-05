# SSH configuration for batuhan
{inputs, ...}: {
  flake.modules.homeManager.wolframite = {
    config,
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.ssh = {
          settings = {
            "github.com" = {
              user = "git";
              hostname = "github.com";
              identitiesOnly = true;
              IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_GITHUB";
            };
            "gitlab.com" = {
              user = "git";
              hostname = "gitlab.com";
              identitiesOnly = true;
              IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_GITLAB";
            };
            "codeberg.org" = {
              user = "git";
              hostname = "codeberg.org";
              identitiesOnly = true;
              IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_CODEBERG";
            };
          };
        };
      }
      (
        # Import liveusb ssh access, if sops is enabled
        lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) {
          # Dispatch the ssh keys
          sops.secrets = {
            "ssh/kayra" = {
              sopsFile = inputs.self + /secrets/user/secrets.yaml;
              path = "${config.home.homeDirectory}/.ssh/id_ed25519_KAYRA";
              mode = "0600";
            };
            "ssh/mergen" = {
              sopsFile = inputs.self + /secrets/user/secrets.yaml;
              path = "${config.home.homeDirectory}/.ssh/id_ed25519_MERGEN";
              mode = "0600";
            };
            "ssh/od-ata" = {
              sopsFile = inputs.self + /secrets/user/secrets.yaml;
              path = "${config.home.homeDirectory}/.ssh/id_ed25519_OD-ATA";
              mode = "0600";
            };
          };
          # Put the keys in the SSH configuration
          programs.ssh.settings = {
            "kayra" = {
              user = "root";
              hostname = "kayra.local";
              IdentityFile = "${config.sops.secrets."ssh/kayra".path}";
              identitiesOnly = true;
            };
            "mergen" = {
              user = "root";
              hostname = "mergen.local";
              IdentityFile = "${config.sops.secrets."ssh/mergen".path}";
              identitiesOnly = true;
            };
            "od-ata" = {
              user = "wolframite";
              hostname = "od-ata.local";
              IdentityFile = "${config.sops.secrets."ssh/od-ata".path}";
              identitiesOnly = true;
            };
          };
        }
      )
    ];
  };
}

# Secretspec
{inputs, ...}: {
  # Module
  flake.modules.homeManager.secretspec-settings = {...}: {
    key = "secretspec-settings#homeManager";
    # TODO; Secretspec module isn't present on 26.05; after migration remove this
    imports = [
      "${inputs.home-manager-unstable}/modules/programs/secretspec.nix"
    ];
    config = {
      programs.secretspec = {
        # We don't want global package available everywhere, we just want to config
        enable = true;
        package = null;
        # Global config options
        settings = {
          providers = {
            local = "keyring://";
          };
        };
      };
    };
  };
}

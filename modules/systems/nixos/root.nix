# Nixos; root user config
{inputs, ...}: {
  flake.modules.nixos.nixos = {
    config,
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      (
        # Load password from hash is sops is available
        lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) {
          # Load root password from sops
          sops.secrets."password/root" = {
            sopsFile = inputs.self + /secrets/host/secrets.yaml;
            neededForUsers = true;
          };
          # Use the set password
          users.users.root.hashedPasswordFile = config.sops.secrets."password/root".path;
        }
      )
    ];
  };
}

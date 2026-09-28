# Nixos; set user root password
{
  inputs,
  den,
  ...
}: {
  # Aspect management
  den = {
    aspects.system = {
      provides.nixos = {
        includes = [
          den.aspects.system._.nixos._.root
        ];
        provides.root = {
          name = "system/nixos/root";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.nixos-root
            ];
          };
        };
      };
    };
  };

  flake.modules.nixos.nixos-root = {
    config,
    lib,
    options,
    ...
  }: {
    key = "nixos-root#nixos";
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

# Secret provisioning for this user
{inputs, ...}: {
  flake.modules = {
    # Secret provisioning

    # To nixos, provision our password hash for user
    nixos.batuhan = {
      lib,
      options,
      config,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) {
        # Load password hash from shared file
        sops.secrets."password/wolframite" = {
          sopsFile = inputs.self + /secrets/host/secrets.yaml;
          neededForUsers = true;
        };
        # Deploy as user password
        users.users.batuhan = {
          hashedPasswordFile = config.sops.secrets."password/wolframite".path;
        };
      };
    };

    # Set default secrets location for user
    homeManager.batuhan = {
      lib,
      options,
      ...
    }: {
      # SOPS setup
      config = lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) {
        sops.defaultSopsFile = lib.mkForce (inputs.self + /secrets/user/wolframite/secrets.yaml);
      };
    };
  };
}

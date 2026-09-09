{
  inputs,
  lib,
  den,
  ...
}: {
  den = {
    schema.user = {
      options = {
        setPassword = lib.mkOption {
          description = "Whether to set user password hash from sops file";
          default = true;
          type = lib.types.bool;
        };
      };
      includes = [
        den.aspects.user.policies.set-user-password-hash
      ];
    };

    aspects.user = {
      policies.set-user-password-hash = {user, ...}:
        lib.optionals user.setPassword [
          (den.lib.policy.include den.aspects.user._.loginPassword)
        ];

      provides.loginPassword = {
        host,
        user,
      }: {
        name = "user/loginPassword(${user.userName}@${host.name})";
        # Add password to nixos
        nixos = {
          lib,
          options,
          config,
          ...
        }: {
          # Guard for existence of sops
          config = lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) {
            sops.secrets."password/${user.userName}" = {
              sopsFile = inputs.self + /secrets/host/secrets.yaml;
              neededForUsers = true;
            };
            # Deploy user password to config
            users.users.${user.userName}.hashedPasswordFile =
              config.sops.secrets."password/${user.userName}".path;
          };
        };
      };
    };
  };
}

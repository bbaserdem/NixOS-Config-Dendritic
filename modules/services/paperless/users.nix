# Paperless user factory function; creates local consumption subdir
{...}: {
  factory.paperlessUser = {
    user,
    directory ? "Shared/Paperless",
    ...
  }: {
    # Provision ingestion subfolder
    nixos."${user}" = {
      config,
      lib,
      options,
      ...
    }: let
      userConsumptionDir = "${config.services.paperless.consumptionDir}/${user}";
    in {
      config = lib.mkMerge [
        (
          lib.mkIf (config.services.paperless.enable == true) {
            # Provision the subfolder if paperless is enabled
            systemd.tmpfiles.settings."30-paperless-${user}" = {
              "${userConsumptionDir}" = {
                # Actual ownership is our user
                "d" = {
                  user = config.users.users.${user}.name;
                  group = config.users.users.${user}.group;
                  mode = "0750";
                };
                # Give ACL read-write access to paperless
                "A+".argument = "u:${config.services.paperless.user}:rwX,m::rwX";
                "a+".argument = "d:u:${config.services.paperless.user}:rwx,d:m::rwx";
              };
            };
          }
        )
        (
          lib.optionalAttrs (lib.hasAttrByPath ["home-manager" "users"] options) {
            # Provision the symlink to our user's home-manager modules
            home-manager.users."${user}".imports = [
              (
                {
                  config,
                  osConfig,
                  ...
                }: {
                  config = lib.mkIf (osConfig.services.paperless.enable == true) {
                    home.file."${directory}" = {
                      source = config.lib.file.mkOutOfStoreSymlink "${userConsumptionDir}";
                      force = true;
                    };
                  };
                }
              )
            ];
          }
        )
      ];
    };
  };
}

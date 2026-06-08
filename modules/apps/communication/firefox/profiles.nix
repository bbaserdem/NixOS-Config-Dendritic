# Generate Firefox Home Manager profile config from localConfig.users.<user>.firefox
{
  config,
  lib,
  ...
}: let
  mkUserModule = user: userCfg: {
    ${user} = {
      pkgs,
      options,
      ...
    }: let
      firefox = userCfg.firefox;

      resolveAttrs = attrs:
        if lib.isFunction attrs
        then attrs {inherit pkgs lib;}
        else attrs;

      mkExtensions = profile:
        (firefox.global.extensions // profile.extensions)
        // {
          packages =
            (resolveAttrs firefox.global.extensions.packages)
            ++ (resolveAttrs profile.extensions.packages);

          settings =
            lib.recursiveUpdate
            (resolveAttrs firefox.global.extensions.settings)
            (resolveAttrs profile.extensions.settings);
        };

      mkProfile = index: profileItem: {
        name = profileItem.name;
        value =
          profileItem.value
          // {
            id =
              if profileItem.value.id == null
              then index
              else profileItem.value.id;

            settings =
              lib.recursiveUpdate
              (resolveAttrs firefox.global.settings)
              (resolveAttrs profileItem.value.settings);

            search = lib.recursiveUpdate firefox.global.search profileItem.value.search;

            extensions = mkExtensions profileItem.value;
          };
      };
    in {
      config = lib.mkMerge [
        {
          programs.firefox = {
            nativeMessagingHosts =
              resolveAttrs
              firefox.global.nativeMessagingHosts;

            profiles =
              firefox.profiles
              |> lib.attrsToList
              |> lib.imap0 mkProfile
              |> builtins.listToAttrs;
          };
        }
        (
          # Dispatch profile names to stylix
          lib.optionalAttrs (lib.hasAttrByPath ["stylix"] options) {
            stylix.targets.firefox.profileNames =
              firefox.profiles
              |> lib.attrNames;
          }
        )
      ];
    };
  };
in {
  config.flake.modules.homeManager =
    config.localConfig.users
    |> lib.filterAttrs (_user: userCfg: (userCfg.firefox or {}) != {})
    |> lib.mapAttrsToList mkUserModule
    |> lib.mkMerge;
}

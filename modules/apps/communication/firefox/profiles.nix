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

      resolvePackages = packages:
        if lib.isFunction packages
        then packages {inherit pkgs lib;}
        else packages;

      mkExtensions = profile:
        (firefox.global.extensions // profile.extensions)
        // {
          packages =
            (resolvePackages firefox.global.extensions.packages)
            ++ (resolvePackages profile.extensions.packages);

          settings = lib.recursiveUpdate firefox.global.extensions.settings profile.extensions.settings;
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

            settings = lib.recursiveUpdate firefox.global.settings profileItem.value.settings;

            search = lib.recursiveUpdate firefox.global.search profileItem.value.search;

            extensions = mkExtensions profileItem.value;
          };
      };
    in {
      config = lib.mkMerge [
        {
          programs.firefox = {
            nativeMessagingHosts = resolvePackages firefox.global.nativeMessagingHosts;

            profiles =
              firefox.profiles
              |> lib.attrsToList
              |> lib.imap0 mkProfile
              |> builtins.listToAttrs;
          };
        }

        (
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
    |> lib.filterAttrs (_user: userCfg: (userCfg.firefox.profiles or {}) != {})
    |> lib.mapAttrsToList mkUserModule
    |> lib.mkMerge;
}

# Profile generation for gecko profiles
{...}: {
  flake.modules.homeManager.gecko-profiles = {
    config,
    lib,
    ...
  }: {
    key = "gecko-profiles/profiles#homeManager";
    config = lib.mkIf (config.gecko.enable or false) (
      let
        # The global profile; to be merged to all profiles
        globalProfile = {
          # Make settings overwritable by the profile-level
          settings = lib.mapAttrs (_: lib.mkOverride 950) config.gecko.settings;
          # Import search and extensions as modules
          search = {...}: config.gecko.search;
          extensions = {...}: config.gecko.extensions;
        };
        # Browser profile; global but browser specific
        browserProfile = browser: {
          # Make settings overwritable by the profile-level
          settings = lib.mapAttrs (_: lib.mkOverride 900) config.gecko.${browser}.settings;
          # Import search and extensions as modules
          search = {...}: config.gecko.${browser}.search;
          extensions = {...}: config.gecko.${browser}.extensions;
        };
        # Name of the default profile
        defaultProfileName =
          config.gecko.profiles
          |> lib.filterAttrs (_: p: p.isDefault)
          |> builtins.attrNames
          |> builtins.head;
        # Calculated profile id's
        profileIds =
          config.gecko.profiles
          |> builtins.attrNames
          |> builtins.filter (n: n != defaultProfileName)
          |> lib.imap1 (i: n: lib.nameValuePair n i)
          |> (l: [(lib.nameValuePair defaultProfileName 0)] ++ l)
          |> builtins.listToAttrs;
        # Profile config option
        profileAttrs =
          config.gecko.profiles
          |> builtins.mapAttrs (
            name: profile:
            # Base set; non-valid options filtered out
              (lib.filterAttrs (n: _: !(builtins.elem n ["stylix"])) profile)
              # Specific overrides
              // {
                # Calculated ID for this profile
                id = profileIds.${name};
                # Pull search and extensions submodules
                search = {...}: profile.search;
                extensions = {...}: profile.extensions;
              }
          );
      in (lib.mkMerge [
        {
          # Global profile settings dispatch
          programs =
            lib.genAttrs
            config.gecko.configuredBrowsers
            (_: {
              profiles =
                lib.genAttrs
                (builtins.attrNames config.gecko.profiles)
                (_: globalProfile);
            });
        }
        {
          # Browser specific global profile settings dispatch
          programs =
            lib.genAttrs
            config.gecko.configuredBrowsers
            (browser: {
              profiles =
                lib.genAttrs
                (builtins.attrNames config.gecko.profiles)
                (_: browserProfile browser);
            });
        }
        {
          # Individual profile settings dispatch
          programs =
            lib.genAttrs
            config.gecko.configuredBrowsers
            (_: {profiles = profileAttrs;});
        }
      ])
    );
  };
}

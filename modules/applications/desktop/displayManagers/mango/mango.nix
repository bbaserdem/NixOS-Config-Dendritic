# Mango desktop
{inputs, ...}: {
  # Flake inputs
  flake-file.inputs = {
    mangowm = {
      # NOTE: mango provides a flake; but the modules are badly setup.
      # There is no home-manager built-in module; so we use the hm module provided upstream.
      # Try not to use more
      url = "github:mangowm/mango";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs-unstable";
        scenefx.inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
    };
  };

  # Den machinery
  den = {
    aspects.desktop = {
      provides.mango = {
        name = "desktop/mango";
        # OS level dispatch
        nixos = {...}: {
          imports = with inputs.self.modules.nixos; [
            mango
            mango-noctalia
          ];
        };
        # User config
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/mango(${user.userName}@${host.name})";
          # Home-manager module
          homeManager = {...}: {
            imports = with inputs.self.modules.homeManager; [
              mango
              mango-clipboard
              mango-noctalia
            ];
          };
          # No stylix theming for mango; yet!
          # stylix = {...}: { };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    nixos.mango = {pkgs, ...}: {
      key = "mango#nixos";
      config = {
        programs = {
          # TODO: In 26.11 mangowc is renamed to mango; fix during migration
          mangowc = {
            enable = true;
            package = pkgs.unstable.mango;
          };
          # Register mango as uwsm session
          uwsm = {
            # UWSM needs to be enabled
            enable = true;
            # Register mango; doesn't ship by default
            waylandCompositors = {
              mango = {
                prettyName = "Mango";
                comment = "Mango compositor managed by UWSM";
                binPath = "/run/current-system/sw/bin/mango";
              };
            };
          };
        };
        # XDG portal is enabled and set-up are done by nixos module;
      };
    };

    # Home-Manager settings
    homeManager.mango = {
      lib,
      pkgs,
      ...
    } @ args: {
      key = "mango#homeManager";
      imports = [
        (inputs.mangowm.hmModules.mango or {})
      ];
      config = {
        wayland.windowManager.mango = {
          # Enable config creation
          enable = true;
          # Pull from osConfig if exists, if not use unstable (TODO: name change 26.11)
          package =
            if (args ? osConfig)
            then args.osConfig.programs.mangowc.package
            else pkgs.unstable.mango;
          # Do not use systemd session; uwsm handles it
          systemd.enable = lib.mkForce false;
        };
      };
    };
  };
}

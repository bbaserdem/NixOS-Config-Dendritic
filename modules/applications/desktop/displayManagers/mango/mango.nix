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
          homeManager = {
            lib,
            options,
            monitors,
            ...
          }: {
            imports = with inputs.self.modules.homeManager; [
              mango
              mango-noctalia
              mango-keybinds
              mango-layout
              mango-settings
              mango-colors
            ];
            # Den-dependent config options
            config = lib.mkMerge [
              (
                lib.optionalAttrs
                (lib.hasAttrByPath ["programs" "noctalia" "settings"] options)
                {
                  programs.noctalia.settings = let
                    # Build all lock-screen layouts for all den-defined monitors
                    layouts =
                      builtins.map
                      (monitor: import ./_lockscreen.nix {inherit lib monitor;})
                      monitors;
                  in {
                    # Screenshot name
                    shell.screenshot.filename_pattern = "${host.name}_%Y%m%d_%H%M%S";
                    # Lockscreen widgets;
                    lockscreen_widgets = {
                      widget_order = lib.concatMap (layout: layout.order) layouts;
                      widget =
                        lib.foldl'
                        (widgets: layout: widgets // layout.widgets)
                        {}
                        layouts;
                    };
                  };
                }
              )
            ];
          };
          # No mango stylix target yet
          stylix = {...}: {
            targets = {
              # TODO: Noctalia is 26.11 release feature; uncomment after updating
              # noctalia.enable = true;
            };
          };
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
        # Install runapp to UWSM launch stuff
        home.packages = with pkgs; [
          unstable.runapp
        ];
      };
    };
  };
}

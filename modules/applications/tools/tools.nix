# System tools
{
  inputs,
  den,
  lib,
  ...
}: {
  # Dispatch modules in aspect
  den = {
    schema = {
      host = {
        # Base should be included by default on all hosts
        includes = [
          den.aspects.tools
          den.aspects.tools.policies.gui-host-dispatch
        ];
        options = {
          tools = lib.mkOption {
            description = "Tool enables on a system";
            default = {};
            type = lib.types.submodule {
              options = {
                enable = lib.mkOption {
                  description = "Enable ALL tooling on this host.";
                  default = false;
                  type = lib.types.bool;
                };
                gui = lib.mkOption {
                  description = "Enable GUI tooling on this host.";
                  default = false;
                  type = lib.types.bool;
                };
              };
            };
          };
        };
      };
    };

    aspects.tools = {
      # Base aspect; this aspect should include all mandatory tools
      name = "tools";
      # Common shared modules for everyone
      os = {...}: {
        imports = [
          inputs.self.modules.generic.tools-utilities
        ];
      };
      # Let users inherit from system; but install for standalone
      homeManager = {...}: {
        imports = [
          inputs.self.modules.homeManager.tools-utilities
        ];
      };

      # Policies for dispatch of the rest
      policies = {
        gui-host-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.gui)
          [
            (den.lib.policy.include den.aspects.tools._.baobab)
          ];
      };

      # Individual apps
      provides.baobab = {...}: {
        name = "tools/baobab";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.baobab
          ];
        };
      };
    };
  };

  # Shored tools to dispatch to all nodes
  # TODO: See which of these can be split into modules
  flake.modules = let
    toolPkgs = pkgs:
      (with pkgs; [
        git
        jq
        rsync
        wget
        curl
        dash
        fd
        findutils
        fastfetch
        hyfetch
      ])
      ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
        kmon # Kernel module checker
        ncdu # Disk usage monitor
        nethogs # Network usage monitor
        lm_sensors # Sensors readout
        lshw # Hardware utility
        killall # Program killer
        dmidecode # Hardware utility
        inotify-tools # File watching
      ]))
      ++ (lib.optionals pkgs.stdenv.hostPlatform.isDarwin (with pkgs; [
        # TODO: stable xquartz is broken
        # unstable.xquartz
        appcleaner
      ]));
  in {
    # Generic utility dispatch to all environments
    generic.tools-utilities = {pkgs, ...}: {
      key = "tools-utilities#generic";
      config = {
        environment.systemPackages = toolPkgs pkgs;
      };
    };
    homeManager.tools-utilities = {pkgs, ...}: {
      key = "tools-utilities#homeManager";
      config = {
        home.packages = toolPkgs pkgs;
      };
    };
    # Other system related apps
    nixos = {
      baobab = {pkgs, ...}: {
        key = "baobab#nixos";
        config = {
          environment.systemPackages = with pkgs; [
            baobab
          ];
        };
      };
    };
  };
}

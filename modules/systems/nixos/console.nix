# Nixos systems console settings
{
  lib,
  den,
  inputs,
  ...
}: {
  den = {
    # Schema for host to customize console settings
    schema.host = {
      options = {
        console = lib.mkOption {
          description = "Console settings for this host (NixOS)";
          default = {};
          type = lib.types.submodule {
            options = {
              keymap = lib.mkOption {
                description = "The keymap to use for the console input.";
                type = lib.types.nullOr lib.types.str;
                default = "dvorak";
              };
              font = lib.mkOption {
                description = "The font name to use for the console font.";
                type = lib.types.str;
                default = "ter-powerline-v24b";
              };
              packages = lib.mkOption {
                description = "Names of font packages to install from pkgs.";
                type = lib.types.listOf lib.types.str;
                default = [
                  "terminus_font"
                  "powerline-fonts"
                ];
              };
            };
          };
        };
      };
    };

    # Aspect to send to console
    aspects.system = {
      provides.nixos = {
        includes = [
          den.aspects.system._.nixos._.console
        ];
        provides.console = {host}: {
          name = "system/nixos/console(@${host.name})";
          nixos = {
            pkgs,
            lib,
            ...
          }: {
            imports = [
              inputs.self.modules.nixos.nixos-console
            ];
            config = {
              console = {
                # Host specific config
                font = host.console.font;
                packages =
                  host.console.packages
                  |> builtins.map (n: pkgs."${n}");
                keyMap = lib.mkIf (host.console.keymap != null) host.console.keymap;
              };
            };
          };
          # Enable stylix theming
          stylix = {
            targets.console = {
              enable = true;
              colors.enable = true;
            };
          };
        };
      };
    };
  };

  flake.modules.nixos.nixos-console = {...}: {
    key = "nixos-console#nixos";
    config = {
      console = {
        earlySetup = true;
      };
    };
  };
}

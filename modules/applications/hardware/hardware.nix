# Hardware integration aspects
{
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
          den.aspects.hardware
        ];
        options = {
          hardware = lib.mkOption {
            description = "Which hardware modules to enable and configure";
            default = {};
            type = lib.types.submodule {};
          };
        };
      };
      user = {
        options = {
          usbAccess = lib.mkOption {
            description = "Whether to give this user access to usb devices w/ root.";
            default = true;
            type = lib.types.bool;
          };
        };
      };
    };

    aspects.hardware = {
      # Base aspect
      name = "hardware";
      provides.to-users = {
        user,
        host,
      }: {
        name = "hardware(${user.userName}@${host.name})";
        # Add the den user to the plugdev group if enabled
        user = {
          lib,
          osConfig,
          ...
        }:
          lib.optionalAttrs
          ((host.class == "nixos") && user.usbAccess)
          {
            extraGroups =
              [
                "plugdev"
              ]
              |> builtins.filter (n: lib.hasAttrByPath ["users" "groups" n] osConfig);
          };
      };
    };
  };
}

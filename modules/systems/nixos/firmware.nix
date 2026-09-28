# Nixos; firmware update daemon
{
  inputs,
  den,
  ...
}: {
  # Aspect dispatch
  den = {
    aspects.system = {
      provides.nixos = {
        includes = [
          den.aspects.system._.nixos._.firmware
        ];
        provides.firmware = {
          name = "system/nixos/firmware";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.nixos-firmware
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.nixos.nixos-firmware = {...}: {
    # Common firmware update daemon to enable on systems
    key = "nixos-firmware#nixos";
    config = {
      services.fwupd = {
        enable = true;
      };
    };
  };
}

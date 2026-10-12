# Yertengri firmware setup
{inputs, ...}: {
  den = {
    # Entity record
    hosts.yertengri = {
      boot.microcode = "amd";
    };
    # Module dispatch
    aspects.yertengri = {
      nixos = {...}: {
        imports = [
          inputs.den.modules.nixos.yertengri-firmware
        ];
      };
    };
  };

  flake.modules.nixos.yertengri-firmware = {...}: {
    key = "yertengri-firmware#nixos";
    config = {
      # Config; empty for now
    };
  };
}

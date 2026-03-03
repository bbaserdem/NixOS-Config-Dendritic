# Graphics configuration for guest nixos OS
{...}: {
  flake.modules.nixos = {
    vm = {...}: {
      hardware.graphics.enable = true;
    };

    # AMD64 specific settings
    vm-amd = {...}: {
      services.xserver.videoDrivers = ["virtio"];
    };

    # ARM specific settings
    vm-arm = {...}: {
      services.xserver.videoDrivers = ["modesetting"];
    };
  };
}

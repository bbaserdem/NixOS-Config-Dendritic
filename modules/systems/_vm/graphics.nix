# Graphics configuration for guest nixos OS
{...}: {
  flake.modules.nixos = {
    virtual-machine = {...}: {
      hardware.graphics.enable = true;
    };

    # AMD64 specific settings
    virtual-machine-amd = {...}: {
      services.xserver.videoDrivers = ["virtio"];
    };

    # ARM specific settings
    virtual-machine-arm = {...}: {
      services.xserver.videoDrivers = ["modesetting"];
    };
  };
}

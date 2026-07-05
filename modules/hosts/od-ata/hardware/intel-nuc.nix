# Od-Ata hardware specific settings
{...}: {
  flake.modules.nixos.od-ata = {
    config,
    lib,
    pkgs,
    ...
  }: {
    config = {
      # Hardware related services
      services = {
        # Thermals management
        thermald.enable = true;
        # Montools for disk health
        smartd.enable = true;
        # Trim
        fstrim.enable = true;
        # Firmware upgrades
        fwupd.enable = true;
      };

      hardware = {
        # Enable microcode updates explicitly
        cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

        # Enable graphics
        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            intel-compute-runtime-legacy1
          ];
        };
      };
    };
  };
}

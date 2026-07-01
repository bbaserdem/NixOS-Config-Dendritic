# Su-ana: frame.work laptop hardware config
{inputs, ...}: {
  flake.modules.nixos.yel-ana = {pkgs, ...}: {
    # Import hardware optimizations
    imports = [
      inputs.hardware.nixosModules.framework-13-7040-amd
    ];

    config = {
      # Framework is optimized for ppd, use that for default for now
      local.powerManagement.backend = "ppd";

      # Explicitly disable fingerprint; enabled by default by framework module
      services.fprintd.enable = false;

      # Framework specific audio enhancement
      hardware.framework.laptop13.audioEnhancement.enable = true;

      # Framework battery health (my battery is pretty bad; but couldn't hurt)
      systemd.services.framework-charge-limit = {
        description = "Set Framework battery charge limit";
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.framework-tool}/bin/framework_tool --charge-limit 80";
          RemainAfterExit = true;
        };
      };
    };
  };
}

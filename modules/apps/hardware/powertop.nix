# Powertop; cpu power monitoring/tuning
{...}: {
  flake.modules.nixos.powertop = {
    lib,
    pkgs,
    ...
  }: {
    # Service enabling is for auto-tuning at startup; we don't want this auto-enabled
    services.powertop = {
      enable = lib.mkOverride 1400 false;
    };

    # We do want to have the tools in userspace though
    environment.systemPackages = with pkgs; [
      powertop
    ];
  };
}

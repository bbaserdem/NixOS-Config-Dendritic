# Powertop; cpu power monitoring/tuning
{...}: {
  flake.modules.nixos.power = {pkgs, ...}: {
    powerManagement = {
      enable = true;
      # Service enabling is only for auto-tuning at startup; we don't want this auto-enabled
      powertop.enable = false;
    };

    services = {
      # Power tuning service
      tuned = {
        enable = true;
        ppdSupport = true;
      };
      # Power events monitoring
      upower = {
        enable = true;
        usePercentageForPolicy = true;
        percentageLow = 20;
        percentageCritical = 10;
        percentageAction = 5;
        criticalPowerAction = "HybridSleep";
      };
    };

    # We do want to have the tools in userspace though
    environment.systemPackages = with pkgs; [
      powertop
    ];
  };
}

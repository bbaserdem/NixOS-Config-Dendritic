# Upower, power event monitor/manager
{...}: {
  flake.modules.nixos.upower = {...}: {
    services.upower = {
      enable = true;
      usePercentageForPolicy = true;
      percentageLow = 20;
      percentageCritical = 10;
      percentageAction = 5;
      criticalPowerAction = "HybridSleep";
    };
  };
}

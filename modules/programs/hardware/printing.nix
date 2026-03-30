# Printer connections
{...}: {
  flake.modules.nixos.printing = {...}: {
    services.printing = {
      enable = true;
      # Enable printer sharing
      listenAddresses = ["*:631"];
      allowFrom = ["all"];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
    };
  };
}

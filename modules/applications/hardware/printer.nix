# Printer access with cups
{...}: {
  flake.modules.nixos.hardware-printer = {...}: {
    key = "hardware-printer#nixos";
    config = {
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
  };
}

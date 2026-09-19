# Bluetooth settings
{...}: {
  flake.modules.nixos.bluetooth = {...}: {
    # Enable bluetooth
    hardware.bluetooth.enable = true;
    # Disable HSP switching in wireplumber
    services.pipewire.wireplumber.extraConfig."11-bluetooth-policy" = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
    };
  };
}

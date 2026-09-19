# Bluetooth settings
{...}: {
  flake.modules.nixos.bluetooth-settings = {...}: {
    key = "bluetooth-settings#nixos";
    config = {
      hardware.bluetooth.enable = true;
      # Disable HSP switching in wireplumber
      services.pipewire.wireplumber.extraConfig."11-bluetooth-policy" = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
    };
  };
}

# Configuring android integration/access to nixos
{...}: {
  # It's a nixos module,
  flake.modules.nixos.android = {pkgs, ...}: {
    programs = {
      # Enable droidcam; and set up kernel modules
      droidcam.enable = true;
      # Enable adb
      adb.enable = true;
    };

    # Open networking ports for adb;
    networking.firewall = {
      allowedTCPPorts = [4747];
      allowedUDPPorts = [4747];
    };

    # Enable the gui for droidcam
    environment.systemPackages = with pkgs; [
      v4l-utils
    ];
  };
}

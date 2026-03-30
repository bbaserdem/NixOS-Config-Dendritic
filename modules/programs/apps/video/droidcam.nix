# Configuring droidcam
{...}: {
  # It's a nixos module,
  flake.modules.nixos.droidcam = {pkgs, ...}: {
    programs = {
      # Enable droidcam
      droidcam.enable = true;

      # Enable the gui
      environment.systemPackages = with pkgs; [
        v4l-utils
      ];
    };
  };
}

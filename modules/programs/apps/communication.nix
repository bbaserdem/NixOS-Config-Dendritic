# Comm integration software suite
{...}: {
  flake.modules.homeManager.communication = {pkgs, ...}: {
    # Install tools
    home.packages = with pkgs; [
      signal-desktop # Messaging
      ferdium # Comms aggregator
      zoom-us # Video conferancing
    ];
  };
}

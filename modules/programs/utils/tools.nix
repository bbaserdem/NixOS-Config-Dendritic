# Generic tools for system
{...}: {
  flake.modules = let
    toolPkgs = pkgs: (with pkgs; [
      git
      jq
      rsync
      wget
      curl
      dash
      neofetch
    ]);
  in {
    homeManager.tools = {pkgs, ...}: {
      home.packages = toolPkgs pkgs;
    };
    nixos.tools = {pkgs, ...}: {
      environment.systemPackages =
        (toolPkgs pkgs)
        ++ (with pkgs; [
          home-manager # Home-manager
          kmon # Kernel module checker
          ncdu # Disk usage monitor
          nethogs # Network usage monitor
          lm_sensors # Sensors readout
          lshw # Hardware utility
          killall # Program killer
          dmidecode # Hardware utility
          inotify-tools # File watching
        ]);
    };
  };
}

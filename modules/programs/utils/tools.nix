# Generic tools for system
{...}: {
  flake.modules = let
    toolPkgs = {
      pkgs,
      lib,
      ...
    }:
      (with pkgs; [
        git
        jq
        rsync
        wget
        curl
        dash
        neofetch
      ])
      ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
        kmon # Kernel module checker
        ncdu # Disk usage monitor
        nethogs # Network usage monitor
        lm_sensors # Sensors readout
        lshw # Hardware utility
        killall # Program killer
        dmidecode # Hardware utility
        inotify-tools # File watching
      ]))
      ++ (lib.optionals pkgs.stdenv.hostPlatform.isDarwin (with pkgs; [
        xquartz
        appcleaner
      ]));
  in {
    # Install tools packages to spaces
    homeManager.tools = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = toolPkgs {inherit pkgs lib;};
    };
    generic.tools = {
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = toolPkgs {inherit pkgs lib;};
    };
  };
}

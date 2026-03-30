# Configuring OBS
{...}: {
  # It's a NixOS module, cause needs to install kernel modules
  flake.modules = {
    nixos.obs = {pkgs, ...}: {
      programs.obs-studio = {
        enable = true;
        enableVirtualCamera = true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          waveform
          droidcam-obs
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vaapi
          obs-gstreamer
          obs-vkcapture
        ];
      };
    };

    # Install from brew in macOS
    darwin.obs = {...}: {
      # We install steam using brew
      homebrew.casks = [
        "obs"
      ];
    };
  };
}

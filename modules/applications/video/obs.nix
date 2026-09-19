# Configuring OBS
{...}: {
  # It's a NixOS module, cause needs to install kernel modules
  flake.modules = {
    nixos.obs-settings = {pkgs, ...}: {
      key = "obs-settings#nixos";
      config = {
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
    };

    # Install obs from brew in macOS
    darwin.obs-settings = {...}: {
      key = "obs-settings#darwin";
      config = {
        homebrew.casks = [
          "obs"
        ];
      };
    };
  };
}

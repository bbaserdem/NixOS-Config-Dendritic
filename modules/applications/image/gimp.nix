# Configuring gimp
{...}: {
  flake.modules.homeManager.gimp-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "gimp-settings#homeManager";
    config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
      home.packages = with pkgs; [
        gimp3-with-plugins
        gimp3Plugins.gmic
        # gimp3Plugins.bimp
        # gimp3Plugins.fourier
        # gimp3Plugins.texturize
        # gimp3Plugins.lightning
        # gimp3Plugins.gimplensfun
        # gimp3Plugins.waveletSharpen
        # gimp3Plugins.exposureBlend
        # gimp3Plugins.resynthesizer
      ];
    };
  };
}

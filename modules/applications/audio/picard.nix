# Add musicbrainz picard to userspace
{...}: {
  flake.modules.homeManager.picard-settings = {pkgs, ...}: {
    key = "music-picard#homeManager";
    config = {
      # TODO: Add picard config here
      home.packages = with pkgs; [
        picard
      ];
    };
  };
}

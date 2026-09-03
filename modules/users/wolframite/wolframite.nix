# Initialize this user
{inputs, ...}: {
  # Establish defaults for wolframite user
  den = {
    schema.user = {
      config,
      lib,
      ...
    }: {
      config = lib.mkIf (config.name == "wolframite") {
        # Media directories
        mediaDirs = {
          documents = {
            location = "Documents";
            externalize = true;
          };
          download = {
            location = "Downloads";
            externalize = true;
          };
          music = {
            location = "Music";
            externalize = true;
          };
          pictures = {
            location = "Pictures";
            externalize = true;
          };
          videos = {
            location = "Videos";
            externalize = true;
          };
          projects = {
            location = "Projects";
            externalize = false;
          };
          publicShare = {
            location = "Shared/Public";
            externalize = false;
          };
        };
        # User icon; host dependent
        icon =
          if (config.host.hostName == "yel-ana")
          then "lensa"
          else if (config.host.hostName == "su-ana")
          then "headshot"
          else "skull";
      };
    };
  };
}

# Initialize this user
{...}: {
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
            externalize = lib.mkDefault true;
            sync = lib.mkDefault true;
          };
          download = {
            location = "Downloads";
            externalize = lib.mkDefault true;
            sync = lib.mkDefault true;
          };
          music = {
            location = "Music";
            externalize = lib.mkDefault true;
            sync = lib.mkDefault true;
          };
          pictures = {
            location = "Pictures";
            externalize = lib.mkDefault true;
            sync = lib.mkDefault true;
          };
          videos = {
            location = "Videos";
            externalize = lib.mkDefault true;
            sync = lib.mkDefault true;
          };
          projects = {
            location = "Projects";
            externalize = lib.mkDefault false;
            sync = lib.mkDefault true;
          };
          publicShare = {
            location = "Shared/Public";
            externalize = lib.mkDefault false;
            sync = lib.mkDefault false;
          };
          android = {
            location = "Shared/Android";
            externalize = lib.mkDefault true;
            sync = lib.mkDefault true;
          };
        };
        # User icon; host dependent (decrypts from secrets/assets/<username>_<icon>.bin)
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

# Media directories for this user
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
          android = {
            location = "Shared/Android";
            externalize = lib.mkDefault true;
          };
          documents = {
            location = "Documents";
            externalize = lib.mkDefault true;
          };
          download = {
            location = "Downloads";
            externalize = lib.mkDefault true;
          };
          music = {
            location = "Music";
            externalize = lib.mkDefault true;
          };
          pictures = {
            location = "Pictures";
            externalize = lib.mkDefault true;
          };
          videos = {
            location = "Videos";
            externalize = lib.mkDefault true;
          };
          projects = {
            location = "Projects";
            externalize = lib.mkDefault false;
          };
          publicShare = {
            location = "Shared/Public";
            externalize = lib.mkDefault false;
          };
          work = {
            location = "Work";
            externalize = lib.mkDefault true;
          };
        };
      };
    };
  };
}

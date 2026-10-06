# Media directories for this user
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

    aspects.wolframite = {
      name = "wolframite";

      # Home-manager settings
      homeManager = {config, ...}: {
        imports = with inputs.self.modules.homeManager; [
          wolframite-flake
        ];
      };
    };
  };

  # Modules
  flake.modules.homeManager = {
    wolframite-flake = {
      config,
      lib,
      ...
    }: {
      key = "wolframite-flake#homeManager";
      config = let
        flakeDir =
          if (config.xdg.userDirs ? projects)
          then "${config.xdg.userDirs.projects}/SystemConfigFlake"
          else "${config.home.homeDirectory}/Projects/SystemConfigFlake";
      in {
        # Flake directory inside projects
        xdg.userDirs.extraConfig.FLAKE = flakeDir;
        home.sessionVariables =
          lib.genAttrs [
            "NH_FLAKE"
            "NH_OS_FLAKE"
            "FLAKE"
          ]
          (_: flakeDir);
      };
    };
  };
}

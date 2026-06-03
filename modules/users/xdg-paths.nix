# XDG paths definition module for users
# This is a seperate definition, because to do dynamic filesystem operations
# (bind mounts); nixos evaluates users.users; which causes infinite recursion
# We break the recursion by providing from one source
{
  lib,
  config,
  ...
}: let
  xdgDirsType = lib.types.submodule {
    options = {
      desktop = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "Desktop";
      };
      documents = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "Documents";
      };
      download = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "Downloads";
      };
      music = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "Music";
      };
      pictures = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "Pictures";
      };
      projects = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "Projects";
      };
      publicShare = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "Public";
      };
      templates = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "Templates";
      };
      videos = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "Movies";
      };
    };
  };
in {
  options = {
    localConfig.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.xdgDirs = lib.mkOption {
          type = xdgDirsType;
          default = {};
          description = "Flake-wide user metadata.";
        };
      });
    };
  };

  # Module that sets xdg.userDirs
  config = let
    usersCfg = config.localConfig.users;
  in {
    flake.modules.homeManager.default = {
      config,
      lib,
      pkgs,
      ...
    }: let
      userCfg = usersCfg.${config.home.username} or {};
      xdgDirs = userCfg.xdgDirs or {};
    in {
      config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        xdg.userDirs =
          xdgDirs
          |> lib.filterAttrs (_name: value: value != null && value != "")
          |> lib.mapAttrs (
            name: value:
              if lib.hasPrefix "/" value || lib.hasPrefix "~/" value
              then throw "localConfig.users.${config.home.username}.xdgDirs.${name} must be relative path; got: '${value}' instead"
              else lib.mkDefault "${config.home.homeDirectory}/${value}"
          );
      };
    };
  };
}

# Create syncthing folder configuration from global config
{
  inputs,
  config,
  ...
}: let
  cfg = config.localConfig.syncthing;
  folders = cfg.folders;
  registeredHost = host: (cfg.hosts.${host}.id or "") != "";
  # Create ignore file
  mkIgnoreText = hostName: folder: ''
    ${cfg.ignore.global}
    ${cfg.ignore.hosts.${hostName} or ""}
    ${folder.ignore.global}
    ${folder.ignore.hosts.${hostName} or ""}
  '';
in {
  config.flake.modules = {
    # Folder generation modules

    # Dispatch folder to main syncthing configuration
    generic.syncthing = {lib, ...}: {
      services.syncthing.settings.folders =
        folders
        |> lib.mapAttrs' (name: folder: {
          name = name;
          value = {
            enable = lib.mkDefault false;
            path = lib.mkOverride 1400 "~/Syncthing/${name}"; # Placeholder path
            devices = lib.mkDefault folder.hosts;
            id = name;
            label = lib.mkDefault (inputs.self.lib.capitalize name);
          };
        });
    };

    # Home-Manager; create folders' path
    homeManager.syncthing = {
      config,
      lib,
      ...
    }: let
      hostName = config.networking.hostName;
      mkRelativePath = name: folder:
        if folder.path == null
        then "Syncthing/${name}"
        else if lib.hasPrefix "~/" folder.path
        then lib.removePrefix "~/" folder.path
        else if lib.hasPrefix "/" folder.path
        then throw "Syncthing folder '${name}' has invalid path '${folder.path}'"
        else folder.path;
    in {
      # Dispatch folder
      services.syncthing.settings.folders =
        folders
        |> lib.filterAttrs (_: folder: lib.elem hostName folder.hosts)
        |> lib.mapAttrs' (name: folder: {
          name = name;
          value = {
            enable = true;
            path = "~/${mkRelativePath name folder}";
            devices = lib.filter (host: (host != hostName) && (registeredHost host)) folder.hosts;
          };
        });
      # Dispatch ignore file
      home.file = lib.mkIf config.services.syncthing.enable (
        folders
        |> lib.filterAttrs (_: folder: lib.elem hostName folder.hosts)
        |> lib.mapAttrs' (name: folder: let
        in {
          name = "${mkRelativePath name folder}/.stignore";
          value.text = mkIgnoreText hostName folder;
        })
      );
    };

    # Nixos; create folder's path and bind mount
    nixos.syncthing = {
      config,
      lib,
      ...
    }: let
      hostName = config.networking.hostName;
      syncUser = config.services.syncthing.user;
      mediaRoot = cfg.mediaRoot;
      # Function for folder path
      ownerExists = owner:
        (owner != null)
        && ((config.users.users.${owner}.enable or false) == true);
      # systemPath only applies where the owning service exists;
      # receivers fall back to placement under the media root
      systemPathActive = folder:
        (folder.systemPath != null) && (ownerExists folder.owner);
      # Function for folder path
      mkNixosPath = name: folder:
        if systemPathActive folder
        then folder.systemPath
        else "${mediaRoot}/${inputs.self.lib.capitalize name}";
      # Check owner existence
      # Split ignore lines into a list of strings
    in {
      # Dispatch the syncthing config
      services.syncthing.settings.folders =
        folders
        |> lib.filterAttrs (_: folder: lib.elem hostName folder.hosts)
        |> lib.mapAttrs' (name: folder: {
          name = name;
          value = {
            enable = true;
            path = mkNixosPath name folder;
            devices = lib.filter (host: (host != hostName) && (registeredHost host)) folder.hosts;
            ignorePerms = true;
            ignorePatterns =
              (mkIgnoreText hostName folder)
              |> lib.splitString "\n";
          };
        });

      # Provision the folders and permissions + ACL
      systemd.tmpfiles.settings =
        folders
        |> lib.filterAttrs (_: folder:
          (lib.elem hostName folder.hosts)
          && !(systemPathActive folder))
        |> lib.mapAttrs' (name: folder: {
          name = "35-syncthing-folder-${name}";
          value = {
            "${mkNixosPath name folder}".d = {
              user =
                if ownerExists folder.owner
                then folder.owner
                else syncUser;
              group = "users";
              mode = "2770";
            };
          };
        });
    };
  };
}

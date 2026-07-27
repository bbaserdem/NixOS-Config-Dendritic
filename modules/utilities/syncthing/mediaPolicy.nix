# Den policy on matching syncthing media folders to entities
# We add to any relevant scope, the syncthingFolder entity
{
  den,
  lib,
  ...
}: let
  enabledOn = host: folder: (builtins.hasAttr host.name folder.endpoints);
  resolveFolder = syncthingFolder:
    den.lib.policy.resolve.shared.to "syncthingFolder" {
      inherit syncthingFolder;
    };
  hasStandaloneHome = host: user:
    builtins.hasAttr
    "${user.userName}@${host.name}"
    (den.homes.${host.system} or {});
in {
  den = {
    policies = {
      # Resolve the user media folders to user+host scope
      syncthing-user-media-folders = {
        host,
        user,
        ...
      } @ ctx:
        if ctx ? syncthingFolder
        then []
        else
          den.syncthingFolders
          |> lib.filterAttrs (
            _: folder:
              (enabledOn host folder)
              && (folder.source.kind == "media")
              && (folder.source.user == user.userName)
              && !(hasStandaloneHome host user)
          )
          |> builtins.attrValues
          |> map resolveFolder;

      # Resolve to scope when standalone home is concerned
      syncthing-home-media-folders = {
        home,
        host,
        ...
      } @ ctx:
        if ctx ? syncthingFolder
        then []
        else
          den.syncthingFolders
          |> lib.filterAttrs (
            _: folder:
              (home.hostName != null)
              && (builtins.hasAttr home.hostName folder.endpoints)
              && (folder.source.kind == "media")
              && (folder.source.user == home.userName)
          )
          |> builtins.attrValues
          |> map resolveFolder;

      # Resolve the user media folders to host only scope when user does not exist on host
      syncthing-headless-media-folders = {host, ...} @ ctx:
        if ctx ? syncthingFolder
        then []
        else
          den.syncthingFolders
          |> lib.filterAttrs (
            _: folder:
              (enabledOn host folder)
              && folder.source.kind == "media"
              && !(builtins.hasAttr folder.source.user host.users)
          )
          |> builtins.attrValues
          |> map resolveFolder;
    };

    aspects.syncthing.includes = [
      den.policies.syncthing-headless-media-folders
      den.policies.syncthing-user-media-folders
      den.policies.syncthing-home-media-folders
    ];
  };
}

# Configuring syncthing pictures directory
{inputs, ...}: {
  flake.modules = inputs.self.factory.syncthingXdg {
    userDir = "documents";
    nameUser = "batuhan";
    aliasUser = "wolframite";
    sharedHosts = [
      "su-ana"
    ];
  };
}

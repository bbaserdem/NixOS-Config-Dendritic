# Configuring syncthing pictures directory
{inputs, ...}: {
  flake.modules = inputs.self.factory.syncthingXdg {
    userDir = "pictures";
    nameUser = "batuhan";
    aliasUser = "wolframite";
    sharedHosts = [
      "su-ana"
    ];
  };
}

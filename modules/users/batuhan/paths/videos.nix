# Configuring synching video directory
{inputs, ...}: {
  flake.modules = inputs.self.factory.syncMediaDir {
    userDir = "videos";
    userDirDarwin = "Movies";
    nameUser = "batuhan";
    aliasUser = "wolframite";
  };
}

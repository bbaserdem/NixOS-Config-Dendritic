# Erlik syncthing config
{inputs, ...}: {
  # TODO; Register with system
  # TODO; Build new topology
  # Android synching inside
  localConfig.syncthing = {
    hosts."erlik".id = "";
    folders.android = {
      owner = "wolframite";
      path = "Android";
      hosts = [
        "yel-ana"
      ];
      ignore = {
        global = ''
          // Android Syncthing ignore file

        '';
      };
    };
  };
}

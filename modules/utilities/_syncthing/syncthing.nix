# Den entity spec for syncthing settings
{lib, ...}: {
  den = {
    schema = let
      syncthingSchema = {...}: {
        options = {
          syncthing = {
            deviceId = lib.mkOption {
              type = lib.types.strMatching "([A-Z2-7]{7}(-[A-Z2-7]{7}){7})?";
              # 56 base32 characters, 8 dash seperated groups of 7 (or empty string)
              default = "";
              description = "Host ID in syncthing for this host";
            };
          };
        };
      };
    in {
      host = syncthingSchema;
      home = syncthingSchema;
    };
  };
}

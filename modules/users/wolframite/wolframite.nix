# Initialize this user
{
  config,
  den,
  ...
}: {
  # Establish defaults for wolframite user
  den = {
    schema.user = {
      config,
      lib,
      ...
    }: {
      config =
        lib.mkIf (config.name == "wolframite") {
        };
    };
  };
}

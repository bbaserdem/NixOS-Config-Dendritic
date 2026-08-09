# setup of den
{
  inputs,
  den,
  ...
}: {
  # Load flake-parts modules
  imports = [
    (inputs.den.flakeModules.default or {})
    # (den.flakeModules.strict or {}) Bugged, throws immediately
  ];

  config = {
    # Den sourcing
    flake-file.inputs = {
      den.url = "github:denful/den/v0.18.0";
    };

    den = {
    };
  };
}

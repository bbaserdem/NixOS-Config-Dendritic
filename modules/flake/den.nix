# setup of den
{inputs, ...}: {
  # Load flake-parts modules
  imports = [
    (inputs.den.flakeModules.default or {})
    # (inputs.den.flakeModules.strict or {}) Bugged, throws immediately
  ];

  config = {
    # Den sourcing
    flake-file.inputs = {
      den.url = "github:denful/den";
      den-diagram.url = "github:denful/den-diagram";
    };
  };
}

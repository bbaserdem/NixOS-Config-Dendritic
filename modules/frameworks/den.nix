# setup of den
{
  inputs,
  den,
  ...
}: {
  # Load flake-parts modules
  imports = [
    (inputs.den.flakeModules.default or {})
    # (inputs.den.flakeModules.strict or {}) Bugged, throws immediately
  ];

  config = {
    # Den sourcing
    flake-file.inputs = {
      den.url = "github:denful/den/v0.18.0";
    };

    # Disable built-in topology by default; we will build it ourselves
    den = {
      schema = {
        # Den's base flake scope
        flake = {
          # Disable den managed flake-system scope
          excludes = [
            # den.policies.flake-to-systems
          ];
        };

        # Den's flake-system scope with system in scope
        flake-system = {
          excludes = [
            # We are removing home entities; don't need this policy
            den.policies.system-to-hm-outputs
            # We are rolling our own policy to do this; don't need it
            den.policies.system-to-os-outputs
            # Disable den managed flake outputs in favor of flake-parts
            den.policies.packages-to-flake
            den.policies.apps-to-flake
            den.policies.checks-to-flake
            den.policies.devShells-to-flake
            den.policies.legacyPackages-to-flake
          ];
        };

        host = {
          excludes = [
            den.policies.host-to-users
            # These policies are generated with embedded names.
            # Have to remove them manually
            (den.lib.policy.mkPolicy "host-to-hm-users" (_: []))
            (den.lib.policy.mkPolicy "host-to-hjem-users" (_: []))
            (den.lib.policy.mkPolicy "host-to-maid-users" (_: []))
          ];
        };
      };
    };
  };
}

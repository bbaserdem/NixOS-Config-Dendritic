# User den configuration
{den, ...}: {
  den = {
    schema = {
      flake-system = {
        excludes = [
          # We are removing home entities, don't need this
          den.policies.system-to-hm-outputs
        ];
      };
    };
  };
}

# Wolframite authentications
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.authentication
      ];

      # Authentication aspect; parametric
      provides.authentication = {
        host,
        user,
      }: {
        name = "wolframite/authentication(${user.userName}@${host.name})";
        homeManager = {
          pkgs,
          lib,
          options,
          config,
          ...
        }: {
          # Modules to load
          imports = with inputs.self.modules.homeManager; [
            wolframite-ssh
            wolframite-pass
          ];
          # Several configuration options
          config = lib.mkMerge [
            {
              # Load our keys from yubikey
              programs.gpg = {
                publicKeys = [
                  {
                    source = inputs.self + /assets/wolframite/gpg-public.asc;
                    trust = 5;
                  }
                ];
              };
            }
          ];
        };
      };
    };
  };
}

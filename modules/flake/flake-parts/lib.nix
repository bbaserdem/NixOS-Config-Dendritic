{
  inputs,
  lib,
  ...
}: {
  # Helper functions for creating system / home-manager configurations

  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
  };

  config.flake.lib = {
    # Nixos system builder, allows customizing the output name parameter
    mkNixos = {
      system,
      name,
      ...
    }: {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.self.modules.generic.nixpkgs
          inputs.self.modules.nixos.${name}
          {nixpkgs.hostPlatform = lib.mkDefault system;}
        ];
      };
    };

    # Nix-Darwin config builder
    mkDarwin = {
      system,
      name,
      ...
    }: {
      ${name} = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          inputs.self.modules.generic.nixpkgs
          inputs.self.modules.darwin.${name}
          {nixpkgs.hostPlatform = lib.mkDefault system;}
        ];
      };
    };

    # Standalone home-manager config builder
    # Will not be used in this flake, but possible
    # Historically, passed host parameter to the configuration to auto-load host specific user config
    # This is not needed with flake-parts, but host-specific behavior requires home-manager as nixos/nix-darwin module
    mkHomeManager = {
      system,
      user,
      ...
    }: {
      ${user} = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = [
          inputs.self.modules.homeManager.${user}
          {nixpkgs.config.allowUnfree = true;}
        ];
      };
    };
  };
}

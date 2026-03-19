{
  self,
  inputs,
  ...
}: {
  # Factory function;
  # Creates flake-parts flake.modules entries for home-manager as nixos/darwin module
  # Takes is attrset with at least username, and optional flags for user roles
  flake.factory.user = {
    username,
    isNormalUser ? true,
    isAdmin ? false,
    isNix ? false,
    ...
  }: {
    # Nixos config for the user, this uses home-manager as nixos module
    nixos."${username}" = {
      lib,
      pkgs,
      ...
    }: {
      # Import home-manager module for nixos
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];
      users.users."${username}" = {
        isNormalUser = isNormalUser;
        home = "/home/${username}";
        extraGroups = lib.optionals isAdmin [
          "wheel"
        ];
        shell = pkgs.zsh;
      };
      programs.zsh.enable = true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPkgs = true;
        users."${username}" = {
          imports = [
            self.modules.homeManager."${username}"
          ];
        };
      };

      nix.settings.trusted-users = lib.optionals isNix [
        username
      ];
    };

    # Nix-darwin config for the given user, uses home-manager as darwin module
    darwin."${username}" = {
      lib,
      pkgs,
      ...
    }: {
      # Import home-manager module for darwin
      imports = [
        inputs.home-manager.darwinModules.home-manager
      ];
      # Configure user
      users.users."${username}" = {
        home = "/Users/${username}";
        shell = pkgs.zsh;
        isHidden = false;
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPkgs = true;
        users."${username}" = {
          imports = [
            self.modules.homeManager."${username}"
          ];
        };
      };

      system.primaryUser = lib.mkIf isAdmin "${username}";
      programs.zsh.enable = true;
    };

    # Home-manager config for the user
    homeManager."${username}" = {
      home.username = "${username}";
    };
  };
}

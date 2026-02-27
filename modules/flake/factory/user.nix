{self, ...}: {
  # Factory function that creates a base user config modules
  # This custom factory option was defined in flake-parts config module
  # Creates nixos, darwin, and homeManager flake-parts modules named after user
  flake.factory.user = {
    username,
    isNormalUser ? true,
    isAdmin ? false,
    isNix ? false,
    ...
  }: {
    # Nixos config for the user
    nixos."${username}" = {
      lib,
      pkgs,
      ...
    }: {
      users.users."${username}" = {
        isNormalUser = isNormalUser;
        home = "/home/${username}";
        extraGroups = lib.optionals isAdmin [
          "wheel"
        ];
        shell = pkgs.zsh;
      };
      programs.zsh.enable = true;

      home-manager.users."${username}" = {
        imports = [
          self.modules.homeManager."${username}"
        ];
      };

      nix.settings.trusted-users = lib.optionals isNix [
        username
      ];
    };

    # Nix-darwin config for the given user
    darwin."${username}" = {
      lib,
      pkgs,
      ...
    }: {
      users.users."${username}" = {
        home = "/Users/${username}";
        shell = pkgs.zsh;
        isHidden = false;
      };

      home-manager.users."${username}" = {
        imports = [
          self.modules.homeManager."${username}"
        ];
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

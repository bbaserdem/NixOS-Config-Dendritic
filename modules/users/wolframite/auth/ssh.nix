# SSH configuration for wolframite
{...}: {
  flake.modules.homeManager.wolframite = {config, ...}: {
    programs.ssh = {
      matchBlocks = {
        "github.com" = {
          user = "git";
          hostname = "github.com";
          identitiesOnly = true;
          extraOptions.IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_GITHUB";
        };
      };
    };
  };
}

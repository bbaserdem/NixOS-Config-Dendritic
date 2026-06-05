# SSH configuration for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {config, ...}: {
    programs.ssh = {
      settings = {
        "github.com" = {
          user = "git";
          hostname = "github.com";
          identitiesOnly = true;
          IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_GITHUB";
        };
        "gitlab.com" = {
          user = "git";
          hostname = "gitlab.com";
          identitiesOnly = true;
          IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_GITLAB";
        };
        "codeberg.org" = {
          user = "git";
          hostname = "codeberg.org";
          identitiesOnly = true;
          IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_CODEBERG";
        };
      };
    };
  };
}

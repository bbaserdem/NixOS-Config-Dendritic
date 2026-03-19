# SSH common config
{...}: {
  flake.modules.home-manager.ssh = {config, ...}: {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        # Servers to bind to by default
        "github.com" = {
          user = "git";
          hostname = "github.com";
          identitiesOnly = true;
          extraOptions.IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_GITHUB";
        };
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "${config.home.homeDirectory}/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
      };
    };
  };
}

# SSH common config
{...}: {
  flake.modules.homeManager.ssh = {config, ...}: {
    programs.ssh = {
      enable = true;
      matchBlocks = {
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

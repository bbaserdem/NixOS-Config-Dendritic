# SSH userspace tooling
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.networking = {
      # Include by default
      includes = [
        den.aspects.networking._.ssh
      ];

      provides.ssh = {
        name = "networking/ssh";
        # Dispatch should work since it's flat include
        provides.to-users = {
          user,
          host,
        }: {
          name = "networking/ssh(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.ssh-settings
            ];
          };
        };
      };
    };
  };

  flake.modules.homeManager.ssh-settings = {config, ...}: {
    key = "ssh-settings#homeManager";
    config = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
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
  };
}

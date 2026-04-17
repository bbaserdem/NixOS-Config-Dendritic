# SSH common config
{...}: {
  flake.modules = {
    # Home config for ssh
    homeManager.ssh = {config, ...}: {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
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

    # Nixos SSH config
    nixos.ssh = {...}: {
      services = {
        # SSH server
        openssh = {
          enable = true;
          # Listen on all interfaces (DHCP IP will be assigned dynamically)
          listenAddresses = [
            {
              addr = "0.0.0.0";
              port = 22;
            }
          ];
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
            # Security settings
            MaxAuthTries = 3;
            ClientAliveInterval = 300;
            ClientAliveCountMax = 2;
            X11Forwarding = true; # We need graphical forwarding
          };
          openFirewall = true;
        };

        # Fail2ban for additional SSH protection
        fail2ban = {
          enable = true;
          maxretry = 3;
          ignoreIP = [
            "127.0.0.0/8"
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
          ]; # Don't ban private networks
          jails = {
            ssh = {
              settings = {
                enabled = true;
                port = "ssh";
                filter = "sshd";
                logpath = "/var/log/auth.log";
                maxretry = 3;
                findtime = 600;
                bantime = 3600;
                action = "iptables[name=SSH, port=ssh, protocol=tcp]";
              };
            };
          };
        };
      };
    };
  };
}

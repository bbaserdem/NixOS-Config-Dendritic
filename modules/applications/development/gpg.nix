# Global GPG configuration
{...}: {
  flake.modules = {
    # GPG settings modules

    # Nixos
    nixos.gpg-settings = {pkgs, ...}: {
      key = "gpg-settings#nixos";
      config = {
        # Install all pinentry packages
        environment.systemPackages = with pkgs; [
          pinentry-all
        ];
        # Further gnupg settings
        programs.gnupg = {
          agent = {
            enableBrowserSocket = true;
            enableExtraSocket = true;
          };
        };
      };
    };

    # Darwin; install pinentry
    darwin.gpg-settings = {pkgs, ...}: {
      key = "gpg-settings#darwin";
      config = {
        environment.systemPackages = with pkgs; [
          pinentry_mac
        ];
      };
    };

    # Both systems; enable gnupg agent system wide
    generic.gpg-settings = {...}: {
      key = "gpg-settings#generic";
      config = {
        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };
      };
    };

    # Home manager users; enable gpg
    homeManager.gpg-settings = {config, ...}: {
      key = "gpg-settings#homeManager";
      config = {
        # Enable GPG
        programs.gpg = {
          enable = true;
          homedir = "${config.xdg.dataHome}/gnupg";
          mutableKeys = true;
          mutableTrust = true;
          # Strong algorithm preferences
          settings = {
            personal-cipher-preferences = "AES256";
            personal-digest-preferences = "SHA512";
            cert-digest-algo = "SHA512";
            s2k-cipher-algo = "AES256";
            s2k-digest-algo = "SHA512";
            s2k-count = "65011712";
          };
        };

        # Enable gpg agent
        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
          # Cache key for 10 minutes, max 2 hours
          defaultCacheTtl = 600;
          maxCacheTtl = 7200;
          defaultCacheTtlSsh = 600;
          maxCacheTtlSsh = 7200;
          # Enable loopback pinentry
          extraConfig = "allow-loopback-pinentry";
        };
      };
    };
  };
}

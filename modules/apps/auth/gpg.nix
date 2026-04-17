# GPG configuration
{...}: {
  flake.modules = {
    # Pinentry methods
    nixos.gpg = {pkgs, ...}: {
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
    darwin.gpg = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        pinentry_mac
      ];
    };
    # Generic gnupg
    generic.gpg = {...}: {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    homeManager.gpg = {config, ...}: {
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
}

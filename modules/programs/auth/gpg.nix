# GPG configuration
{...}: {
  flake.modules = {
    # Pinentry methods
    nixos.gpg = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        pinentry-all
      ];
    };
    darwin.gpg = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        pinentry_mac
      ];
    };

    homeManager.gpg = {config, ...}: {
      # Enable GPG
      programs.gpg = {
        enable = true;
        homedir = "${config.xdg.dataHome}/gnupg";
        mutableKeys = true;
        mutableTrust = true;
        # Strong algorithm preferences
        personal-cipher-preferences = "AES256";
        personal-digest-preferences = "SHA512";
        cert-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        s2k-digest-algo = "SHA512";
        s2k-count = "65011712";
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

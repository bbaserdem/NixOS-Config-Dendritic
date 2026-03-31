# GPG configuration
{...}: {
  flake.modules.homeManager.gpg = {config, ...}: {
    # Enable GPG
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
      mutableKeys = true;
      mutableTrust = true;
    };

    # Enable gpg agent
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 86400;
      defaultCacheTtlSsh = 86400;
      maxCacheTtl = 86400;
      maxCacheTtlSsh = 86400;
      extraConfig = "allow-loopback-pinentry";
    };
  };
}

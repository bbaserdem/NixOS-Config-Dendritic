# Avahi; zeroconf network discovery
{...}: {
  flake.modules.nixos.avahi = {lib, ...}: {
    services.avahi = {
      enable = true;
      openFirewall = true;
      # Enable DNS resolution by us as well
      nssmdns4 = true;
      # Publishing rules
      publish = {
        # Enable publishing, these are all mkDefault so can be overridden at host level
        enable = lib.mkDefault true;
        # Publish us as <hostname>.local
        addresses = lib.mkDefault true;
        # Don't need to advertise as a desktop computer; off by default
        workstation = lib.mkDefault false;
        # Allow users to publish avahi service files
        userServices = lib.mkDefault true;
        # Don't leak hardware info to the network
        hinfo = false;
        # Tell services that .local is a domain worth browsing for services
        domain = true;
      };
    };
  };
}

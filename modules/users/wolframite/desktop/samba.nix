# Provision shared directory through samba for this user
{config, ...}: {
  flake.modules = config.factory.sambaUser {
    user = "wolframite";
    guest = true;
    readOnly = false;
    sambaShare = true;
    hostsAllow = "192.168.1.";
  };
}

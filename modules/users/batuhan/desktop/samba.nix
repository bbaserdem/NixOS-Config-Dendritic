# Provision shared directory through samba for this user
{inputs, ...}: {
  flake.modules = inputs.self.factory.userSamba {
    user = "batuhan";
    guest = true;
    readOnly = false;
    sambaShare = true;
    hostsAllow = "192.168.1.";
  };
}

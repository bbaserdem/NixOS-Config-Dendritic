# SSH key permissions generation
{...}: {
  flake.modules.nixos.ssh = {...}: {
    # Heal key permissions if they are harmed in any way
    systemd.tmpfiles.settings."11-ssh-key-permissions" = {
      "/etc/ssh/ssh_host_ed25519_key".z = {
        user = "root";
        group = "root";
        mode = "0600";
      };
      "/etc/ssh/ssh_host_ed25519_key.pub".z = {
        user = "root";
        group = "root";
        mode = "0644";
      };
    };
  };
}
